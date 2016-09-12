if (typeof(navigator.requestMIDIAccess) != 'undefined') {
  navigator
    .requestMIDIAccess({'sysex': true}) //TODO: make sysex optional
    .then(
      function(midi) {
        console.log(midi);
        console.log(midi.inputs);
        console.log('midi input 1: ', midi.inputs[0]);
      },
      function(error) {
          console.log("uh-oh! Something went wrong!  Error code: " + err.code)
      }
    )
}
