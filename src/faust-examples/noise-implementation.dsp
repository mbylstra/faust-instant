random = +(12345) ~ *(1103515245); // "linear congruential"
RANDMAX	= 2147483647.0; // = 2^31-1 = MAX_SIGNED_INT in 32 bits

noise = random / RANDMAX;

process = noise;
