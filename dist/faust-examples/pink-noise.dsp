import("music.lib");
import("effect.lib");


pinkFilter =
    f : (+ ~ g)
    with {
      f(x) = 0.04957526213389*x - 0.06305581334498*x' +
             0.01483220320740*x'';
      g(x) = 1.80116083982126*x - 0.80257737639225*x';
    };

process = noise : pinkFilter :  _ * 0.2;
