function [T_stat, T_dyn] = required_thrust(Re_cruise, v_cruise, v_stall, W, AR,
                                           S, c, b, t_max, x_max,
                                           S_H, c_H, b_H, t_max_H, x_max_H,
                                           S_V, c_V, b_V, t_max_V, x_max_V)

  fprintf("\n\nReuired Thrust\n");

  warning("Please note that you're now getting answers with oswald's efficiency factor set to 0.85, g = 9.8065 m/s^{2} and density set to sea level (1.225 kg/m^{3}), if you want to change it, then do so manually in the \"required_thrust.m\" file");

  %% constants
  e = 0.85;
  rho = 1.225;
  g = 9.8065;

  %% functions
  cf_laminar = @(Re) 1.328/sqrt(Re);
  cf_turbulent = @(Re) 0.455/(log10(Re))^2.58;
  cf = @(Re) cf_laminar(Re) * (Re<=10^5) + cf_turbulent(Re) * (Re>=10^6) + (cf_laminar(Re)*(10^6-Re)/(10^6-10^5) + cf_turbulent(Re)*(Re-10^5)/(10^6-10^5))*(Re>10^5 && Re<10^6);
  FF = @(t, x) 1 + 0.6 / x * t + 100 * t^4;
  S_wet = @(S_W, t) 2 * (1 + 0.2 * t) * S_W;
  CD0 = @(Re, t, x, S_W, S) (cf(Re) * FF(t, x) * S_wet(S, t))/S;

  %% Total Drag Coefficient
  CD_0 = CD0(Re_cruise, t_max, x_max, S, S) + CD0(Re_cruise, t_max_H, x_max_H, S, S_H) + CD0(Re_cruise, t_max_V, x_max_V, S, S_V)

  K = 1/e/AR/pi;
  [~, CLmax] = analysis("NACA 6415", AR, 'max');
  CD = CD_0 + K*CLmax^2
  V0 = v_stall;
  V_LOF = 1.3 * v_stall; % 1.1~1.3
  q = 1/2 * rho * ((V_LOF - V0)/sqrt(2))^2;
  V_max = (1.25*v_cruise); % 1.2~1.3
  mu = 0;
  T_stat = W * ((V_LOF^2 - V0^2)/2/9.8065/3 + q*CD/(W/S)) + mu*(1-q*CLmax/(W/S));
  T_dyn = W * (rho * V_max^2 * CD_0 * 1/(2*W/S) + 2*(W/S)*K / (1.225*V_max^2));

end % end function

