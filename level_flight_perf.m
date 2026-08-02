function [CD, V, Tr, Pr] = level_flight_perf(CL, geom, aero, flight)
%LEVEL_FLIGHT_PERF  Compute drag coefficient, trim velocity, thrust
%   required and power required for steady level flight at a given
%   trim lift coefficient.
%
%   Drag polar:      CD = CD0 + k*CL^2
%   Lift equilibrium: L = W = 0.5*rho*V^2*S*CL  ->  V = sqrt(2W/(rho*S*CL))
%   Thrust required:  Tr = D = 0.5*rho*V^2*S*CD
%   Power required:   Pr = Tr * V
%
%   Inputs:
%     CL     - trim lift coefficient [-]
%     geom   - struct with field S (planform area, m^2)
%     aero   - struct with fields CD0, k
%     flight - struct with fields rho, W
%
%   Outputs:
%     CD - drag coefficient [-]
%     V  - level-flight trim velocity [m/s]
%     Tr - thrust required [N]
%     Pr - power required [W]

    CD = aero.CD0 + geom.k * CL^2;

    if CL <= 0
        % Non-physical trim point (no lift) - flag with NaN rather than
        % dividing by zero / returning a complex velocity.
        V = NaN; Tr = NaN; Pr = NaN;
        return;
    end

    V  = sqrt(2 * flight.W / (flight.rho * geom.S * CL));
    Tr = 0.5 * flight.rho * V^2 * geom.S * CD;
    Pr = Tr * V;
end
