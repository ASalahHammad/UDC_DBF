%% -*- texinfo -*-
%% [Ixx, Iyy, Izz] = inertia(m, b, c_H, L_H)

function [Ixx, Iyy, Izz] = inertia(m, b, c_H, L_H)
  l = L_H + c_H;
  Ixx = m * (0.11 * b)^2;
  Iyy = m * (0.175 * l)^2;
  Izz = m * (0.19 * (b + l))^2;
end

