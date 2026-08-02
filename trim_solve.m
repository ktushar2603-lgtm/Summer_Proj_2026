function [de_trim, CL_trim] = trim_solve(alpha, aero)
%TRIM_SOLVE  Solve the longitudinal trim condition of a tailless
%   (elevon-controlled) delta wing at a given angle of attack.
%
%   For steady, trimmed flight the net pitching moment about the
%   reference point must be zero:
%       Cm = Cm0 + Cmalpha*alpha + Cmde*de = 0
%   which gives the trim elevon deflection in closed form (linear
%   aerodynamics, single unknown de -> no iteration needed):
%       de_trim = -(Cm0 + Cmalpha*alpha) / Cmde
%
%   The corresponding trim lift coefficient follows from the linear
%   lift equation:
%       CL_trim = CL0 + CLalpha*alpha + CLde*de_trim
%
%   Inputs:
%     alpha - angle of attack [rad]
%     aero  - struct with fields Cm0, Cmalpha, Cmde, CL0, CLalpha, CLde
%
%   Outputs:
%     de_trim - trim elevon deflection [rad]
%     CL_trim - trim lift coefficient  [-]

    de_trim = -(aero.Cm0 + aero.Cmalpha * alpha) / aero.Cmde;
    CL_trim = aero.CL0 + aero.CLalpha * alpha + aero.CLde * de_trim;
end
