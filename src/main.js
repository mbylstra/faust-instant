// pull in desired CSS/SASS files
require( './styles/main.scss' );


// inject bundled Elm app into div#main
var Elm = require( './Main' );
var elm = Elm.Main.embed( document.getElementById( 'main' ) );


var audioContext = new AudioContext();
var BUFFER_SIZE = 1024;
var currFaustCode = null;
var currFactory = null;
var currDsp = null;



elm.ports.compileFaustCode.subscribe(function(faustCode) {
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
      faust.deleteDSPInstance(currDsp);
    }
    currDsp = faust.createDSPInstance(currFactory, audioContext, BUFFER_SIZE);
    currDsp.connect(audioContext.destination);       // connect the source to the context's destination (the speakers)
  }
});


// console.log("faust", faust);
// fetch('faustcode/bogus.lib')
// fetch('faustcode/math.lib')
// fetch('faustcode/most-basic.dsp')
// fetch('faustcode/echo.dsp')
// fetch('faustcode/noise.dsp').then((response) => {
// fetch('faust/noise-implementation.dsp').then((response) => {
//   return response.text();
// }).then((code) => {
// });
