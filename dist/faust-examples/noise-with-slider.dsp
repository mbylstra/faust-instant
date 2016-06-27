import ("music.lib");
// noise level controlled by a slider
process = noise * vslider("volume", 0, 0, 1, 0.1);
