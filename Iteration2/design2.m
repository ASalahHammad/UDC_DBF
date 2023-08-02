clear
clc,clc,clc
close all

AIRFOILS = {"NACA 4415", "NACA 4418", "NACA 6415", "NACA 6418"};
figure;
for i = 1:length(AIRFOILS)
  AIRFOIL = AIRFOILS{i};
  fprintf("\nAirfoil: %s\n", AIRFOIL);
  airfoil = importdata(strcat(AIRFOIL,".csv"));
  alpha = airfoil.data(6:end,1); Cl = airfoil.data(6:end,2);
  Cl_alpha = (Cl(25)-Cl(15)) / (alpha(25)-alpha(15)) / pi * 180;
  Cl_0 = Cl(alpha==0);
  for AR = [5, 6, 7]
    CL_alpha = Cl_alpha / (1 + Cl_alpha / pi / AR);
    CL0 = -CL_alpha*ALPHA_0(alpha, Cl)*pi/180;
    [~, ind] = max(Cl);
    CLmax = CL0 + CL_alpha*alpha(ind)*pi/180;
    fprintf("  At AR = %d, CL_max = %d\n", AR, CLmax);
  end
  subplot(2,2,i);
  plot(alpha, Cl); hold on; grid on; xlabel("alpha"); ylabel("Cl"); title(AIRFOIL); ylim([min(Cl), max(Cl)]);
end

function [alpha_0] = ALPHA_0(alpha, Cl)
  %% return alpha at which zero lift occurs
  i = find(Cl==0);
  if(i)
    alpha_0 = alpha(i);
    return;
  else % then interpolate
    for j = 1:length(Cl)
      if Cl(j)>0
        alpha_0 = alpha(j-1) + (0 - Cl(j-1)) * (alpha(j) - alpha(j-1)) / (Cl(j) - Cl(j-1));
        return
      end
    end
  end
end
