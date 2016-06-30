import ("music.lib");
freq = nentry("freq", 440, 20, 20000, 1);
process = osc(freq);
