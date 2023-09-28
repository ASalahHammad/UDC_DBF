function [] = some_code()
  clear
  clc, clc, clc
  b = .73 * 2
  chord = .2:.005:.3;
  for c = chord
    c
    AR = b / c;
    [~, CLmax] = analysis("NACA 8415", AR, "max");
    CxCLmax = c * CLmax
  end
end

