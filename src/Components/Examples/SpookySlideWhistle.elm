  , ( "Spooky Slide Whistle"
    , """

      declare author "Michael Bylstra";

      import("math.lib");
      import("effect.lib");
      import("filter.lib");


      eq =
        low_shelf(LL,FL) : peak_eq(LP,FP,BP) : high_shelf(LH,FH)
        with {
          LL = 0;
          FL = 200;
          LP = 0;
          FP = 440;
          Q = 40;
          BP = FP/Q;
          LH = -40;
          FH = hslider("Spooky Slide Whistle", 3000,20,10000,0.1) : smooth(0.999);
        };


      clip(threshold) = asymetricClip(threshold, negativeThreshold)
        with {
          negativeThreshold = threshold * -1;
          asymetricClip(top, bottom) = min(top) : max(bottom);
        };

      hearingProtector = clip(0.1);

      filterSection = eq : clip(0.5);
      mix = +;
      quietNoise = noise * 0.01;
      noInputMixer = quietNoise : mix ~ eq;

      process = noInputMixer : hearingProtector;
