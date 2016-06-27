import("music.lib");


quietNoise = noise * 0.1;
noInputMixer = quietNoise : + ~ _;
process = noInputMixer;
