// pull in desired CSS/SASS files

require('codemirror/lib/codemirror.css');
// require('codemirror/theme/monokai.css');
// require('../node_modules/codemirror/theme/twighlight.css');
require('./styles/tomorrow-night-eighties.css');
require( './styles/main.scss' );

require('codemirror/mode/clike/clike.js');
require('./js/codemirror-faust-mode/faust.js');
var CodeMirror = require('codemirror/lib/codemirror.js');

// inject bundled Elm app into div#main
var Elm = require( './Main' );
var elm = Elm.Main.embed( document.getElementById( 'main' ) );


var audioContext = new AudioContext();
var NUM_POLY_VOICES = 3;
var currFaustCode = null;
var currFactory = null;
var currDsp = null;
var editor = null;
// var mainGainNode = audioContext.createGain();
var polyphonic = false;
// mainGainNode.gain.value = 1;

function midiToFreq(note) {
    return 440.0 * Math.pow(2.0, (note - 69.0) / 12.0);
}

// var audioMonitor = audioContext.createScriptProcessor(bufferSize);
// audioMonitor.onaudioprocess = function(audioProcessingEvent) {
//
//   // The input buffer is the song we loaded earlier
//   var inputBuffer = audioProcessingEvent.inputBuffer;
//
//   // The output buffer contains the samples that will be modified and played
//   var outputBuffer = audioProcessingEvent.outputBuffer;
//
//   // Loop through the output channels (in this case there is only one)
//   for (var channel = 0; channel < outputBuffer.numberOfChannels; channel++) {
//     var inputData = inputBuffer.getChannelData(channel);
//     var outputData = outputBuffer.getChannelData(channel);
//     // Loop through the 4096 samples
//     for (var sample = 0; sample < inputBuffer.length; sample++) {
//       // make output equal to the same as the input
//       outputData[sample] = inputData[sample];
//     }
//   }
//
//   var audioData = audioProcessingEvent.inputBuffer.getChannelData(0);
//   // let total = 0;
//   // let length = audioData.length;
//   // for (let i = 0; i < length; i++) {
//   //     total += Math.abs(audioData[i]);
//   // }
//   // var avg = total / length;
//   // var avgRms = Math.sqrt(avg) * 3.0;
//   // self.setState({amplitude: avgRms});
//
//   // just get first value for now:
//   var currentValue = audioData[0]
//   elm.ports.incomingAudioMeterValue.send(currentValue);
// }
//
// audioMonitor.connect(audioContext.destination);


// var analyserNode = audioContext.createAnalyser();
// // analyserNode.fftSize = 2048;
// // analyserNode.fftSize = 4096;
// analyserNode.fftSize = 256;
// var analyserBufferLength = analyserNode.frequencyBinCount;
// console.log('analyserBufferLength', analyserBufferLength);
// var analyserDataArray = new Float32Array(analyserBufferLength);

elm.ports.compileFaustCode.subscribe(function(payload) {

  // document.getElementById("spinner").style.display = "block";
  setTimeout(function() {
    // This is a massive hack due to issues with concurrency and ordering in Elm!

    polyphonic = payload.polyphonic; //global
    bufferSize = payload.bufferSize;
    var faustCode = payload.faustCode;
    var numVoices = payload.numVoices;


    console.log("faustCode:", faustCode);
    //var args = ["-I", "http://" + window.location.hostname + "/faust-stdlib/"];
    var args = ["-I", "http://localhost:8080/faust-stdlib/"];
    faust.error_msg = null; //clear old error message
    var newFactory = faust.createDSPFactory(faustCode, args);

    if (faust.error_msg) {
      console.log("faust.error_msg: ", faust.error_msg);
      elm.ports.incomingCompilationErrors.send(faust.error_msg);
    } else {
      elm.ports.incomingCompilationErrors.send(null);
      var currFactory = newFactory
      if (currDsp != null) {
        // currDsp.disconnect(analyserNode);
        currDsp.disconnect(audioContext.destination);
        deleteDSPInstance(currDsp);
      }
      if (polyphonic) {
        currDsp = faust.createPolyDSPInstance(currFactory, audioContext, bufferSize, numVoices);
      } else {
        currDsp = faust.createDSPInstance(currFactory, audioContext, bufferSize);
      }
      console.log('currDsp', currDsp);
      console.log('controls', currDsp.controls());
      elm.ports.incomingDSPCompiled.send(currDsp.controls());
      console.log('json', JSON.parse(currDsp.json()));
      // console.log('json.ui', currDsp.json().outputs);
      // currDsp.connect(analyserNode);
      currDsp.connect(audioContext.destination);
      // analyserNode.connect(mainGainNode);
      // mainGainNode.connect(audioMonitor);
    }
  },0); // This is a massive hack so that the spinner shows _before_ we start
        // compiling!

});

elm.ports.elmAppInitialRender.subscribe(function() {
  var codeMirrorElement = document.getElementById('codemirror');

  editor = CodeMirror.fromTextArea(codeMirrorElement, {
    mode: 'faust',
    // lineWrapping: true,
    // extraKeys: {
    //   'Ctrl-Space': 'autocomplete'
    // },
    lineNumbers: true,
    // theme: 'monokai'
    theme: 'tomorrow-night-eighties'
  });
  editor.focus();
  editor.on('change', function() {
    var currentFaustCode = editor.getValue();
    elm.ports.incomingFaustCode.send(currentFaustCode);
  });
});

elm.ports.updateFaustCode.subscribe(function(faustCode) {
  editor.getDoc().setValue(faustCode);
})

// elm.ports.updateMainVolume.subscribe(function(value) {
//   mainGainNode.gain.value = value;
// })

elm.ports.setControlValue.subscribe(function(e) {
  if (currDsp) {
    var path = e[0];
    var value = e[1];
    console.log('setctrlvalue', path, value);
    currDsp.setValue(path, value);
  }
})

elm.ports.setPitch.subscribe(function(pitch) {
  if (currDsp) {
    if (polyphonic) {
      currDsp.keyOn(null, pitch, 1.0);
    } else {
      currDsp.setValue('/0x00/freq', midiToFreq(pitch));
    }
  }
})


/**
 * A fork of deleteDSPInstance inside webaudio-asm-wrapper.js that
 * doesn't assume the dsp is connected to the destination
 */
function deleteDSPInstance(dsp) {
    if (dsp.numIn > 0) {
        for (var i = 0; i < dsp.numIn; i++) {
            Module._free(HEAP32[(dsp.ins >> 2) + i]);
        }
        Module._free(dsp.ins);
    }

    if (dsp.numOut > 0) {
        for (var i = 0; i < dsp.numOut; i++) {
            Module._free(HEAP32[(dsp.outs >> 2) + i]);
        }
        Module._free(dsp.outs);
    }

    Module._free(dsp.dsp);
}

// function sendFFTData() {
//   analyserNode.getFloatFrequencyData(analyserDataArray);
//   var floatData = Array.prototype.slice.call(analyserDataArray);
//   elm.ports.incomingFFTData.send(floatData);
//   requestAnimationFrame(sendFFTData);
// }
// sendFFTData();

// setInterval(function() {
  // requestAnimationFrame(sendFFTData);
// }, 1000);
