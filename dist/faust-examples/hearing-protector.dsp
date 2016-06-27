_clip(lo,hi) = min(hi) : max(lo);
clip(threshold) = _clip(threshold * -1, threshold);
hearingProtector = clip(0.1);
process = hearingProtector;
