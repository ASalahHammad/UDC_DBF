clear
clc, clc

% comment this if you're using matlab
pkg load io

data = xlsread('../Session 3_ Airframe Design/MTOW Estimation Balsa.xlsx');
battery = 0.4;
payload = 1.2;
UW = (battery+payload);

% Wing
fprintf("\n\nWing NACA 6415\n");
AR = 6.7;
[Clmax, CLmax] = analysis("NACA 6415", AR, 'max')  % if you'll choose this manually: 1.2~1.5
f = polyfit(data(:,2), data(:,1), 2);
W = polyval(f, UW)*2

v_stall = 5; % 5~8
rho = 1.225;
S = W / (1/2 * rho * v_stall^2 * CLmax)
b = sqrt(AR * S)
b = 1.3
c = b / AR
c = 0.2

%%% Horizontal Tail
fprintf("\n\nHorizontal Tail\n");
V_H = .6; % 0.3~0.6
S_H_S_W = .35;
AR_H = 4;
S_H = S_H_S_W * S % 0.2~0.25
MAC = 2/3 * c * (3/2);
L_H = V_H * S * MAC / S_H
b_H = sqrt(AR_H*S_H)
c_H = b_H / AR_H
L_H = 0.44
%%%
%%%% Vertical Tail
fprintf("\n\nVertical Tail\n");
L_V = L_H;
V_V = .06; % 0.02~0.05
AR_V = 5;
S_V = V_V * S * b / L_V
c_V = c_H
b_V = AR_V*c_V
S_V = c_V*b_V
%c_V = S_V / b_V
%%%
%%%%% Stability
fprintf("\n\nStability\n");
SM = 0.2
XP = .1;
XG = XP - MAC * SM
ZG = -0.04
v_cruise = 22
alpha_trim = 2
%cl_beta = -0.00004
%cn_beta = 0.00143
%
ac_len = c_H + L_H
Ixx = W * (0.11 * b)^2 / 9.8
Iyy = W * (0.175 * ac_len)^2 / 9.8
Izz = W * (0.19 * (b + ac_len))^2 / 9.8
%
%
%%%
Re_takeoff = 46185.81;
Re_cruise = 250000.0;
cf_laminar = @(Re) 1.328/sqrt(Re);
cf_turbulent = @(Re) 0.455/(log10(Re))^2.58;
cf = @(Re) cf_laminar(Re) * Re<=10^5 + cf_turbulent(Re) * Re>=10^6 + (cf_laminar(Re)*(10^6-Re)/(10^6-10^5) + cf_turbulent(Re)*(Re-10^5)/(10^6-10^5))*(Re>10^5 && Re<10^6);
FF = @(t, x) 1 + 0.6 / x * t + 100 * t^4;
S_wet = @(S_W, t) 2 * (1 + 0.2 * t) * S_W;
CD0 = @(Re, t, x, S_W) (cf(Re) + FF(t, x) + S_wet(S_W, t))/S_W;
%

fprintf("\n\nReuired Thrust\n");
t_max = .15;
x_max = .4;
t_max_H = 0.09;
x_max_H = 0.3;
t_max_V = 0.09;
x_max_V = 0.3;
%
CD_0 = CD0(Re_cruise, t_max, x_max, S) + CD0(Re_cruise, t_max_H, x_max_H,S) + CD0(Re_cruise, t_max_V, x_max_V, S)
e = 0.85;
K = 1/e/AR/pi;
[~, CL_cruise] = analysis("NACA 6415", AR, alpha_trim)
CD = CD_0 + K*CL_cruise^2
T = 1/2 * rho *v_cruise^2 * S * CD
T_dyn = W * rho * (1.25*v_cruise)^2 * CD_0 * 1/(2*W/S) + 2*(W/S) / (1.225*pi*0.7*AR*(1.25*v_cruise)^2)

