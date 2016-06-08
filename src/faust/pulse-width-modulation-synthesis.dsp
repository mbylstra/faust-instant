music = library("music.lib");
oscillator = library("oscillator.lib");
supercollider = library("sc.lib");


process = supercollider.lfpulse(pulseFrequency, initialPulsePhase, pulseWidth) * 0.3;
pulseFrequency = 440.0;
initialPulsePhase = 0.0;
pulseWidth = 0.5 + pulseWidthModulator;

pulseWidthModulatorFrequency = 110.0;
pulseWidthModulator = oscillator.osc(pulseWidthModulatorFrequency) * timbreLfo;

timbreLfoFrequency = 0.7;
timbreLfoRange = 0.4;
timbreLfo = oscillator.osc(timbreLfoFrequency) * timbreLfoRange;
