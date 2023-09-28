%%  -*- texinfo -*-
%%  @noindent
%%  if you're using matlab, fix this line that reads the airfoil to be:	airfoil = importdata(strcat("airfoils_analysis/",AIRFOIL,".csv"));
%%  @noindent
%%  please note that the XFLR5 analysis on airfoils that are not 'NACA' is usually not so consistent, this is not a mistake of the code

function [Cl, CL] = analysis(AIRFOIL, AR, AOA)

  try
    airfoil = importdata(strcat("airfoils_analysis/",AIRFOIL));
  catch % nofile
    error("This analysis doesn't yet exist, please conduct it and save the required analysis file inside the folder \"airfoils\" analyses");
  end
  alpha = airfoil.data(6:end,1);  cl = airfoil.data(6:end,2);
  slope = 0; cnt = int8(length(alpha) / 5):int8(length(alpha) / 2);
  for i = cnt
      slope = slope + (cl(i)- cl(i-2)) / (alpha(i)-alpha(i-2));
  end
  slope = slope / length(cnt);
  Cl_alpha = slope * 180 / pi;
  Cl_0 =  cl(alpha==0);
  CL_alpha = Cl_alpha / (1 + Cl_alpha / 180 / AR);

  %% find alpha at which zero lift occurs
  i = find( cl==0);
  if(i)
    alpha_0 = alpha(i);
  else % then interpolate
    for j = 1:length( cl)
      if  cl(j)>0
        alpha_0 = alpha(j-1) + (0 -  cl(j-1)) * (alpha(j) - alpha(j-1)) / ( cl(j) -  cl(j-1));
        break;
      end
    end
  end
  CL0 = -CL_alpha*alpha_0 * pi/180;

  if(AOA=='max')
      [Cl, ind] = max(cl);
      alpha(ind);
      CL = CL0 + CL_alpha*alpha(ind) * pi/180;
      return;
  else
      ind = find(alpha==AOA);
      if(ind)
          Cl = cl(ind);
          CL = CL0 + CL_alpha*alpha(ind) * pi/180;
          return;
      else % then interpolate
          for i = 1:length(alpha)
              if(alpha(i)>AOA)
                  Cl = cl(i-1) + (AOA-alpha(i-1)) * (cl(i)-cl(i-1)) / (alpha(i)-alpha(i-1));
                  CL = CL0 + CL_alpha*AOA * pi/180;
                  return;
              end
          end
      end
  end
end % end function

