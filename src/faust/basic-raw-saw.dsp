periodInSamples = 44100 / 440.0;
increasingInts = 1 : + ~ _ : _ - 1;
normalize(maximum, value) = (value/maximum)*2 - 1;
repeatingRamp = increasingInts % periodInSamples;
process = repeatingRamp : normalize(periodInSamples - 1);
