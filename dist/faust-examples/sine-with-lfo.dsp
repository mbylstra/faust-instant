import("music.lib");
import("effect.lib");


lfoDepth = 10.0;
lfoFreq = 3.0;
lfo = osc(lfoFreq) * lfoDepth;


process = osc(440.0 + lfo) * 0.2;
