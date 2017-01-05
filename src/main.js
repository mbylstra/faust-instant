// pull in desired CSS/SASS files

require('codemirror/lib/codemirror.css');
//require('codemirror/theme/monokai.css');
//require('../node_modules/codemirror/theme/twighlight.css');
require('./styles/mbylstra-signup-view.css' );
// This is css generated by elm-css. You must first run `build-elm-css`
require('./styles/elm-css-build/main.css');

require('./styles/tomorrow-night-eighties.css');
require('./styles/main.scss' );

require('codemirror/mode/clike/clike.js');
require('./js/codemirror-faust-mode/faust.js');
var CodeMirror = require('codemirror/lib/codemirror.js');

var WebFont = require('webfontloader');



// This is SUPER important if you want elm-css-webpack-loader to do anything!
// It doesn't work at the moment :(
// require('./Stylesheets.elm')

// inject bundled Elm app into div#main
var Elm = require( './Main.elm' );

// TODO: get the program in localstorage
//
// c
// localstorage.g
//
//
localStorage.setItem("current-file", JSON.stringify({"title": "title1", "code": "blah"}));

var currentFileData = JSON.parse(localStorage.getItem("current-file"));

JSON.parse(localStorage.getItem("current-file"));
var elm = Elm.Main.embed(document.getElementById('main'), currentFileData);


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

var bufferEventCallback = function(currentTime) {
  elm.ports.incomingAudioBufferClockTick.send(currentTime);
}

elm.ports.compileFaustCode.subscribe(function(payload) {

  // document.getElementById("spinner").style.display = "block";
  setTimeout(function() {
    // This is a massive hack due to issues with concurrency and ordering in Elm!
    //

    polyphonic = payload.polyphonic; //global
    bufferSize = payload.bufferSize;
    var faustCode = payload.faustCode;
    var numVoices = payload.numVoices;


    console.log("faustCode:", faustCode);
    var args = ["-I", window.location.href + "/faust-stdlib/"];
    faust.error_msg = null; //clear old error message
    var newFactory = faust.createDSPFactory(faustCode, args);
    // var factoryCompute = newFactory.getFactoryCompute();

    // maybe we can run the factory compute at this point?
    //

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
        // TODO properly
        currDsp = faust.createPolyDSPInstance(currFactory, audioContext, bufferSize, numVoices);
      } else {
        currDsp = faust.createDSPInstance(currFactory, audioContext, bufferSize, bufferEventCallback);
        elm.ports.incomingBufferSnapshot.send(currDsp.debugComputeMono());
        currDsp.setHandler(function(address, value) {
          elm.ports.incomingBarGraphUpdate.send({address: address, value: value});
        });
      }
      // console.log('currDsp', currDsp);
      // console.log('controls', currDsp.controls());
      var json = JSON.parse(currDsp.json());
      console.log("json", json);
      elm.ports.incomingDSPCompiled.send(json);

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
    theme: 'tomorrow-night-eighties',
  });
  // updateCodeMirrorSize();

  editor.focus();
  editor.on('change', function() {
    var currentFaustCode = editor.getValue();
    elm.ports.incomingFaustCode.send(currentFaustCode);
  });
});

elm.ports.layoutUpdated.subscribe(function() {
  updateCodeMirrorSize();
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

function updateCodeMirrorSize() {
    var codeMirrorHolder = document.getElementById('code-editor-holder');
    codeMirrorHolder.style.overflow = "hidden";
    setTimeout(function() {
      // var rect = codeMirrorHolder.getBoundingClientRect();
      // var width = codeMirrorHolder.offsetWidth;
      // var height = codeMirrorHolder.offsetHeight;
      var width = codeMirrorHolder.clientWidth;
      // console.log('width', width);
      var height = codeMirrorHolder.clientHeight;
      // console.log('height', height);
      editor.setSize(width, height);
      // editor.setSize(width, 100);
      // editor.setSize("100%", "100%");
      // editor.setSize("auto", "auto");
      setTimeout(function() {
        // codeMirrorHolder.style.overflow = "visible";
        // codeMirrorHolder.style.overflow = "";
      },500);

    },50);
    // console.log(codeMirrorHolder);
}

elm.ports.measureText.subscribe(function(s) {
  var textMeasurer = document.getElementById('measure-text');
  textMeasurer.innerText = s;
  var width = textMeasurer.offsetWidth;
  // console.log('width', width);
  elm.ports.incomingTextMeasurements.send(width);
})

WebFont.load({
  google: {
    families: [
      'Bungee Hairline',
      'Roboto:100',
    ]
  },
  active: function() {
    elm.ports.incomingWebfontsActive.send({});
  },
});

// elm.ports.requestMidiAccess.subscribe(function() {
//  For now, we just try to connect midi anyway
if (typeof(navigator.requestMIDIAccess) != 'undefined') {
  navigator
    //.requestMIDIAccess({'sysex': true}) //TODO: make sysex optional
    // sysex causes wierd permissions issues in OSX, and we don't need it
    .requestMIDIAccess()
    .then(
      function(midi) {
        // outputs = midi.outputs()
        // lexiconOutput = outputs[0]
        // lexiconOutput.send(bytes)
        // console.log('midi', midi);
        // console.log('midiInputs', midiInputs);
        // console.log('>>midi.inputs.size', midi.inputs.size);
        var midiInputs = Array.from(midi.inputs.values());
        // console.log('midi.inputs.keys()', midi.inputs.keys());
        if (midi.inputs.size > 0) {
          var midiInput = midiInputs[0];
          midiInput.onmidimessage = function(midiMessage) {
              // console.log(midiMessage);
              var midiEventTypeValue = midiMessage.data[0];
              // console.log('note', midiMessage.data[1]);
              // this is a total guess! (no internet)
              // var elmData = {
              //   _ctor: 'Tuple3',
              //   _0: midiMessage.data[0],
              //   _1: midiMessage.data[1],
              //   _2: midiMessage.data[2],
              // }
              var elmData = [
                midiMessage.data[0],
                midiMessage.data[1],
                midiMessage.data[2],
              ]
              elm.ports.rawMidiInputEvents.send(elmData);

              //TODO:
              //  convert uint8array to a 3-tuple of ints
              //  This stuff should be done in elm:
              //    144 == note on
              //    128 == note off
              //  we should do most of this stuff in elm. Just turn the 8intarray into a regular array of ints
          }
        } else {
          console.log('TODO: midi is supported, but no inputs connected');
        }
      },
      function(error) {
        console.log("uh-oh! Something went wrong!  Error code: " + error.code)
        //TODO: make a midi connection error event
      }
    )
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
