%%  -*- texinfo -*-
%%  @deftypefn {} {@var{[]} =} fn ()
%%  @noindent
%%  Please note that this code is just a general algorithm for the aerodynamic design of airplane, however it's not the only one, you might find yourself in the need of another algorithm due to having different design parameters, different required tasks or different conditions
%%  @noindent
%%  There are lots of parameters in this code that are not calculated but chosen by the designer, a suitable range for choosing them is usually given as a comment beside the assignment operation
%%  @example
%%  @group
%%  @code{@var{V_H} = 0.3 % horizontal tail volume coefficient 0.3~0.6}
%%  @end group
%%  @end example
%%  @noindent
%%  It is also important to note that you are not obliged to take each result from this code as is, it is very common to manually edit the parameters in between lines of code according to what you see suitable
%%  @noindent
%%  The results of the code with the parameters on GitHub are not necessarily good for any purpose, consider the results of the premade code as just an illustrative example that you can edit as you wish, you're the only one responsible if you take the results from the code and apply them in real life
%%  @seealso{inertia, required_thrust}
%%  @end deftypefn

clear
clc, clc, clc

%%  Do this if you need weight estimation
%battery = 0.4;
%payload = 0.6;
%UW = (payload + battery)*1.3;
%pkg load io
%data = xlsread("../Session 3_ Airframe Design/MTOW Estimation Balsa.xlsx");
%f = polyfit(data(:,2), data(:,1), 2);
%m = f(UW)
%W = m*9.8
m = 2.0 % kg
W = m * 9.8

%%  Wing
fprintf("\n\nWing NACA 6415\n");
AR = 6; %
[Clmax, CLmax] = analysis("NACA 6415", AR, 'max') % if you'll choose this manually, you might want to start with values: 1.2~1.5
v_stall = 8; % 5~8
rho = 1.225;
S = W / (1/2 * rho * v_stall^2 * CLmax)
b = sqrt(AR * S)
c = b / AR

%%% Horizontal Tail
fprintf("\n\nHorizontal Tail\n");
V_H = .6; % 0.3~0.6
S_H_S_W = .25;
AR_H = 4; % 3~5
S_H = S_H_S_W * S % 0.2~0.25
MAC = 2/3 * c * (3/2)
L_H = V_H * S * MAC / S_H
b_H = sqrt(AR_H*S_H)
c_H = b_H / AR_H

%%  Vertical Tail
fprintf("\n\nVertical Tail\n");
L_V = L_H; % usually the same
V_V = .05; % 0.02~0.05
AR_V = 3; % 3~5
S_V = V_V * S * b / L_V
b_V = sqrt(AR_V * S_V)
c_V = b_V/AR_V

%%  Stability
fprintf("\n\nStability\n");
SM = 0.2 % should be around 20%
XP = .161 % this can be calculated from XFLR5 Fixed Lift analysis
XG = XP - MAC * SM

%%  Moments of inertia
[Ixx Iyy Izz] = inertia(m, b, c_H, L_H)

%%  Required static and dynamic thrust
v_cruise = 13.2 % m/s. this can be calculated from XFLR5 Fixed Lift analysis
Re_cruise = 250000.0;
t_max = .121;
x_max = .198;
t_max_H = 0.04;
x_max_H = 0.3;
t_max_V = 0.04;
x_max_V = 0.3;
[T_stat, T_dyn_MTOW] = required_thrust(Re_cruise, v_cruise, v_stall, W, AR,
                                           S, c, b, t_max, x_max,
                                           S_H, c_H, b_H, t_max_H, x_max_H,
                                           S_V, c_V, b_V, t_max_V, x_max_V)
fprintf("Static thrust = %d N = %d g\n", T_stat, T_stat*1000/9.8065)
fprintf("Dynamic thrust with payload = %d N = %d g\n", T_dyn_MTOW, T_dyn_MTOW*1000/9.8065)
[~, T_dyn_empty] = required_thrust(Re_cruise, v_cruise, v_stall, W-0.5*9.8, AR,
                                           S, c, b, t_max, x_max,
                                           S_H, c_H, b_H, t_max_H, x_max_H,
                                           S_V, c_V, b_V, t_max_V, x_max_V)
fprintf("Dynamic thrust without payload = %d N = %d g\n", T_dyn_empty, T_dyn_empty*1000/9.8065)

