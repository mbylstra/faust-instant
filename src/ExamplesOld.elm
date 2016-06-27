
examplesRaw : List (String, String)
examplesRaw =
  [ ( "White Noise"
    , """
      import("music.lib");
      process = noise;
      """
    )
  , ( "Whistling Noise"
    , """
      import("music.lib");
      import("effect.lib");

      filterQ = 0.97;
      filterFrequency = 2000.0;
      process = noise : moog_vcf_2bn(filterQ, filterFrequency);
      """
    )
  , ( "Sine with vibrato"
    , """
      import("music.lib");
      import("effect.lib");

      lfoDepth = 10.0;
      lfoFreq = 3.0;
      lfo = osc(lfoFreq) * lfoDepth;

      process = osc(440.0 + lfo);
      """
    )
  , ( "\"Pulse Width Modulation Synthesis\""
    , """
      music = library("music.lib");
      oscillator = library("oscillator.lib");
      supercollider = library("sc.lib");


      process = supercollider.lfpulse(pulseFrequency, initialPulsePhase, pulseWidth);
      pulseFrequency = 440.0;
      initialPulsePhase = 0.0;
      pulseWidth = 0.5 + pulseWidthModulator;

      pulseWidthModulatorFrequency = 110.0;
      pulseWidthModulator = oscillator.osc(pulseWidthModulatorFrequency) * timbreLfo;

      timbreLfoFrequency = 0.7;
      timbreLfoRange = 0.4;
      timbreLfo = oscillator.osc(timbreLfoFrequency) * timbreLfoRange;
      """
    )
  , ( "Basic Saw wave implementation"
    , """
      periodInSamples = 44100 / 440.0;
      increasingInts = 1 : + ~ _ : _ - 1;
      normalize(maximum, value) = (value/maximum)*2 - 1;
      repeatingRamp = increasingInts % periodInSamples;
      process = repeatingRamp : normalize(periodInSamples - 1);
      """
    )
  , ( "Noise with Slider"
    , """
      import ("music.lib");
      // noise level controlled by a slider
      process = noise * vslider("volume", 0, 0, 1, 0.1);
      """
    )
  , ( "Sine with keyboard pitch"
    , """
      import ("music.lib");
      freq = nentry("freq", 440, 20, 20000, 1);
      process = osc(freq);
      """
    )
  , ( "Kisana"
    , """
      process = vgroup("Kisana",environment{declare name    "Kisana";
      declare author  "Yann Orlarey";

      //Modifications GRAME July 2015

      /* ========= DESCRITPION =============

      - Kisana : 3-loops string instrument (based on Karplus-Strong)
      - Head = Silence
      - Tilt = High frequencies
      - Front = High + Medium frequencies
      - Bottom = High + Medium + Low frequencies
      - Left = Minimum brightness
      - Right = Maximum birghtness
      - Front = Long notes
      - Back = Short notes

      */

      import("music.lib");

      KEY = 60;  // basic midi key
      NCY = 15;   // note cycle length
      CCY = 15;  // control cycle length
      BPS = 360;  // general tempo (beat per sec)


      process = kisana;


      //-------------------------------kisana----------------------------------
      // USAGE:  kisana : _,_;
      //     3-loops string instrument
      //-----------------------------------------------------------------------

      kisana = vgroup("Kisana", harpe(C,11,48), harpe(C,11,60), (harpe(C,11,72) : *(1.5), *(1.5))
        :>*(l))
        with {
          l = -20 : db2linear;//hslider("[1]Volume",-20, -60, 0, 0.01) : db2linear;
          C = hslider("[2]Brightness[acc:0 0 -10 0 10]", 0.2, 0, 1, 0.01) : automat(BPS, CCY, 0.0);
        };



      //----------------------------------Harpe--------------------------------
      // USAGE:  harpe(C,10,60) : _,_;
      //    C is the filter coefficient 0..1
      //     Build a N (10) strings harpe using a pentatonic scale
      //    based on midi key b (60)
      //    Each string is triggered by a specific
      //    position of the "hand"
      //-----------------------------------------------------------------------
      harpe(C,N,b) =   hand(b) <: par(i, N, position(i+1)
                    : string(C,Penta(b).degree2Hz(i), att, lvl)
                    : pan((i+0.5)/N) )
                 :> _,_
        with {
          att  = hslider("[3]Resonance[acc:2 0 -10 0 12]", 4, 0.1, 10, 0.01);
          hand(48) = vslider("h:[1]Instrument Hands/1 (Note %b)[unit:pk][acc:1 1 -10 0 14]", 0, 0, N, 1) : int : automat(120, CCY, 0.0);
          hand(60) = vslider("h:[1]Instrument Hands/2 (Note %b)[unit:pk][acc:1 1 -10 0 14]", 2, 0, N, 1) : int : automat(240, CCY, 0.0);
          hand(72) = vslider("h:[1]Instrument Hands/3 (Note %b)[unit:pk][acc:1 1 -10 0 10]", 4, 0, N, 1) : int : automat(480, CCY, 0.0);
          //lvl  = vslider("h:loop/level", 0, 0, 6, 1) : int : automat(BPS, CCY, 0.0) : -(6) : db2linear;
          lvl = 1;
          pan(p) = _ <: *(sqrt(1-p)), *(sqrt(p));
          position(a,x) = abs(x - a) < 0.5;
          db2linear(x)  = pow(10, x/20.0);

        };


      //----------------------------------Penta-------------------------------
      // Pentatonic scale with degree to midi and degree to Hz conversion
      // USAGE: Penta(60).degree2midi(3) ==> 67 midikey
      //        Penta(60).degree2Hz(4)   ==> 440 Hz
      //-----------------------------------------------------------------------

      Penta(key) = environment {

        A4Hz = 440;

        degree2midi(0) = key+0;
        degree2midi(1) = key+2;
        degree2midi(2) = key+4;
        degree2midi(3) = key+7;
        degree2midi(4) = key+9;
        degree2midi(d) = degree2midi(d-5)+12;

        degree2Hz(d) = A4Hz*semiton(degree2midi(d)-69) with { semiton(n) = 2.0^(n/12.0); };

      };


      //----------------------------------String-------------------------------
      // A karplus-strong string.
      //
      // USAGE: string(440Hz, 4s, 1.0, button("play"))
      // or    button("play") : string(440Hz, 4s, 1.0)
      //-----------------------------------------------------------------------

      string(coef, freq, t60, level, trig) = noise*level
                    : *(trig : trigger(freq2samples(freq)))
                    : resonator(freq2samples(freq), att)
        with {
          resonator(d,a)  = (+ : @(d-1)) ~ (average : *(a));
          average(x)    = (x*(1+coef)+x'*(1-coef))/2;
          trigger(n)     = upfront : + ~ decay(n) : >(0.0);
          upfront(x)     = (x-x') > 0.0;
          decay(n,x)    = x - (x>0.0)/n;
          freq2samples(f) = 44100.0/f;
          att       = pow(0.001,1.0/(freq*t60)); // attenuation coefficient
          random      = +(12345)~*(1103515245);
          noise       = random/2147483647.0;
        };


      }.process);
      """
    )
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
      """
    )
  ]
