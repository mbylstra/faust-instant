declare name "Faust Oscillator Library";
declare author "Julius O. Smith (jos at ccrma.stanford.edu)";
declare copyright "Julius O. Smith III";
declare version "1.11";
declare license "STK-4.3"; // Synthesis Tool Kit 4.3 (MIT style license)

// Slight modification by Michael Bylstra to use "freq" control label instead of "frequency"

import("oscillator.lib");

virtual_analog_oscillator_demo_ = signal with {
  osc_group(x) = vgroup("[0] VIRTUAL ANALOG OSCILLATORS
    [tooltip: See Faust's oscillator.lib for documentation and references]",x);

  // Signals
  saw = (amp/3) *
    (sawtooth(sfreq) + sawtooth(sfreq*detune1) + sawtooth(sfreq*detune2));
  sq = (amp/3) *
    (square(sfreq) + square(sfreq*detune1) + square(sfreq*detune2));
  tri = (amp/3) *
    (triangle(sfreq) + triangle(sfreq*detune1) + triangle(sfreq*detune2));
  pt = (amp/3) * (pulsetrain(sfreq,ptd)
                + pulsetrain(sfreq*detune1,ptd)
                + pulsetrain(sfreq*detune2,ptd));
  ptN = (amp/3) * (pulsetrainN(N,sfreq,ptd)
                + pulsetrainN(N,sfreq*detune1,ptd)
                + pulsetrainN(N,sfreq*detune2,ptd)) with {N=3;};
  pn = amp * pink_noise;

  signal = ssaw*saw + ssq*sq + stri*tri
  	   + spt*((ssptN*ptN)+(1-ssptN)*pt)
	   + spn*pn + sei*_;

  // Signal controls:
  signal_group(x) = osc_group(hgroup("[0] Signal Levels",x));
  ssaw = signal_group(vslider("[0] Sawtooth [style:vslider]",1,0,1,0.01));

  pt_group(x) = signal_group(vgroup("[1] Pulse Train",x));
  ssptN = pt_group(checkbox("[0] Order 3
    [tooltip: When checked, use 3rd-order aliasing suppression (up from 2)
     See if you can hear a difference with the freq high and swept]"));
  spt = pt_group(vslider("[1] [style:vslider]",0,0,1,0.01));
  ptd = pt_group(vslider("[2] Duty Cycle [style:knob]",0.5,0,1,0.01))
        : smooth(0.99);

  ssq = signal_group(vslider("[2] Square [style:vslider]",0,0,1,0.01));
  stri = signal_group(vslider("[3] Triangle [style:vslider]",0,0,1,0.01));
  spn = signal_group(vslider(
      "[4] Pink Noise [style:vslider]
       [tooltip: Pink Noise (or 1/f noise) is Constant-Q Noise, meaning that it has the same total power in every octave (uses only amplitude controls)]",0,0,1,0.01));
  sei = signal_group(vslider("[5] Ext Input [style:vslider]",0,0,1,0.01));

  // Signal Parameters
  knob_group(x) = osc_group(hgroup("[1] Signal Parameters", x));
  af_group(x) = knob_group(vgroup("[0]", x));
  ampdb  = af_group(hslider("[1] Mix Amplitude [unit:dB] [style:hslider]
    [tooltip: Sawtooth waveform amplitude]",
    -20,-120,10,0.1));
  amp = ampdb : db2linear : smooth(0.999);

  freq = nentry("freq", 440, 20, 20000, 1);

  detune1 = 1 - 0.01 * knob_group(
    vslider("[3] Detuning 1 [unit:%%] [style:knob]
      [tooltip: Percentange frequency-shift up or down for second oscillator]",
      -0.1,-10,10,0.01));
  detune2 = 1 + 0.01 * knob_group(
    vslider("[4] Detuning 2 [unit:%%] [style:knob]
      [tooltip: Percentange frequency-shift up or down for third detuned oscillator]",
    +0.1,-10,10,0.01));
  portamento = knob_group(
    vslider("[5] Portamento [unit:sec] [style:knob] [scale:log]
      [tooltip: Portamento (frequency-glide) time-constant in seconds]",
      0.1,0.001,10,0.001));
  sfreq = freq : smooth(tau2pole(portamento));
};

process = virtual_analog_oscillator_demo_;
