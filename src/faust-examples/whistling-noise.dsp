import("music.lib");
import("effect.lib");


filterQ = 0.97;
filterFrequency = 2000.0;
process = noise : moog_vcf_2bn(filterQ, filterFrequency) : _ * 0.2;
