%% ========================================================================
%  main_trim_analysis.m
%
%  Project Assignment 4 - Trim, Thrust Required, and Power Required
%  Analysis of a Cropped Delta Wing UAV
%
%  Description:
%   This script computes, for a sweep of angle of attack (alpha), the
%   trim elevon deflection, trim lift coefficient, drag coefficient,
%   level-flight velocity, thrust required and power required of a
%   cropped delta wing (wing-alone / tailless) UAV. Results are stored,
%   tabulated, and plotted (Phase 1-3 of the assignment).
%
%  Structure (modular):
%     main_trim_analysis.m   -> top-level driver (this file)
%     compute_geometry.m     -> planform geometry (Preprocessing Calc.)
%     trim_solve.m           -> trim elevon deflection & CL at one alpha
%     level_flight_perf.m    -> V, CD, Tr, Pr at one alpha
%
%  Run:  just press Run in MATLAB (no inputs required).
%  ========================================================================

clear; clc; close all;

%% 1. GIVEN DATA -----------------------------------------------------
geom.Cr = 0.9;      % root chord [m]
geom.Ct = 0.15;     % tip chord  [m]
geom.b  = 1.5;      % span       [m]
geom.e  = 0.89;     % Oswald efficiency factor

aero.CD0     = 0.03;     % zero-lift drag coefficient
aero.Cm0     = 0.01;     % pitching moment coeff at alpha=0, de=0
aero.CLalpha = 2.92;     % lift-curve slope             [per rad]
aero.CLde    = 0.265;    % elevon lift effectiveness    [per rad]
aero.Cmalpha = -0.292;   % pitch stiffness               [per rad]
aero.Cmde    = -0.4;     % elevon pitch effectiveness    [per rad]
aero.CL0     = 0.0;      % NOTE: not given in assignment data table;
                          % assumed 0 (typical for a reflexed tailless
                          % delta where Cm0 already captures the
                          % camber/twist pitching contribution).
                          % <-- state this assumption in your report.

flight.mass = 3.5;    % UAV mass [kg]
flight.rho  = 1.225;  % air density, sea level [kg/m^3]
flight.g    = 10;     % gravity [m/s^2]  (as given in assignment)
flight.W    = flight.mass * flight.g;   % weight [N]

%% 2. PREPROCESSING: GEOMETRY -----------------------------------------
geom = compute_geometry(geom);

fprintf('=== Geometry ===\n');
fprintf('Taper ratio   lambda = %.4f\n', geom.lambda);
fprintf('Planform area    S   = %.4f m^2\n', geom.S);
fprintf('Aspect ratio    AR   = %.4f\n', geom.AR);
fprintf('Induced factor   k   = %.4f\n', geom.k);
fprintf('Weight           W   = %.2f N\n\n', flight.W);

%% 3. ANGLE OF ATTACK SWEEP (Phase 1) ---------------------------------
alpha_deg = 0:0.5:12;                 % deg, as specified
alpha_rad = deg2rad(alpha_deg);
n = length(alpha_deg);

% Preallocate result arrays
de_trim = zeros(1,n);   CL_trim = zeros(1,n);  CD_trim = zeros(1,n);
V       = zeros(1,n);   Tr      = zeros(1,n);  Pr      = zeros(1,n);
LDratio = zeros(1,n);   L32D    = zeros(1,n);

for i = 1:n
    a = alpha_rad(i);

    % --- Trim solution: elevon deflection & trim CL ---
    [de, CL] = trim_solve(a, aero);
    de_trim(i) = de;
    CL_trim(i) = CL;

    % --- Level-flight performance: CD, V, Tr, Pr ---
    [CD, Vi, Tri, Pri] = level_flight_perf(CL, geom, aero, flight);
    CD_trim(i) = CD;
    V(i)  = Vi;
    Tr(i) = Tri;
    Pr(i) = Pri;

    % --- Phase 2: performance metrics ---
    LDratio(i) = CL / CD;          % range parameter (jet-type)
    L32D(i)    = CL^1.5 / CD;      % endurance parameter (prop-type)
end

%% 4. RESULTS TABLE -----------------------------------------------------
Results = table(alpha_deg', rad2deg(de_trim)', CL_trim', CD_trim', ...
                 V', Tr', Pr', LDratio', L32D', ...
    'VariableNames', {'alpha_deg','de_trim_deg','CL_trim','CD_trim', ...
                       'V_m_s','Tr_N','Pr_W','CL_over_CD','CL32_over_CD'});

disp('=== Results table (head) ===');
disp(Results(1:10,:));

writetable(Results, 'results_table.csv');

% Key performance points
[minTr, iTr] = min(Tr);
[minPr, iPr] = min(Pr);
[maxLD, iLD] = max(LDratio);
[maxL32D, iL32] = max(L32D);

fprintf('\n=== Key performance points ===\n');
fprintf('Min Thrust required = %.3f N at alpha = %.1f deg, V = %.2f m/s\n', ...
        minTr, alpha_deg(iTr), V(iTr));
fprintf('Min Power required  = %.3f W at alpha = %.1f deg, V = %.2f m/s\n', ...
        minPr, alpha_deg(iPr), V(iPr));
fprintf('Max CL/CD           = %.3f at alpha = %.1f deg\n', maxLD, alpha_deg(iLD));
fprintf('Max CL^1.5/CD       = %.3f at alpha = %.1f deg\n', maxL32D, alpha_deg(iL32));

%% 5. PLOTS (Phase 3) ----------------------------------------------------
figure('Name','Trim elevon deflection');
plot(alpha_deg, rad2deg(de_trim), '-o','LineWidth',1.5,'MarkerSize',4);
xlabel('Angle of attack, \alpha (deg)');
ylabel('Trim elevon deflection, \delta_e (deg)');
title('Trim Elevon Deflection vs Angle of Attack'); grid on;
saveas(gcf, '01_de_trim_vs_alpha.png');

figure('Name','Lift coefficient');
plot(alpha_deg, CL_trim, '-o','LineWidth',1.5,'MarkerSize',4);
xlabel('Angle of attack, \alpha (deg)'); ylabel('Lift coefficient, C_L');
title('Trim Lift Coefficient vs Angle of Attack'); grid on;
saveas(gcf, '02_CL_vs_alpha.png');

figure('Name','Drag coefficient');
plot(alpha_deg, CD_trim, '-o','LineWidth',1.5,'MarkerSize',4);
xlabel('Angle of attack, \alpha (deg)'); ylabel('Drag coefficient, C_D');
title('Drag Coefficient vs Angle of Attack'); grid on;
saveas(gcf, '03_CD_vs_alpha.png');

figure('Name','Thrust required');
plot(V, Tr, '-o','LineWidth',1.5,'MarkerSize',4);
xlabel('Flight velocity, V (m/s)'); ylabel('Thrust required, T_r (N)');
title('Thrust Required vs Flight Velocity'); grid on;
saveas(gcf, '04_Tr_vs_V.png');

figure('Name','Power required');
plot(V, Pr, '-o','LineWidth',1.5,'MarkerSize',4);
xlabel('Flight velocity, V (m/s)'); ylabel('Power required, P_r (W)');
title('Power Required vs Flight Velocity'); grid on;
saveas(gcf, '05_Pr_vs_V.png');

figure('Name','Velocity vs alpha');
plot(alpha_deg, V, '-o','LineWidth',1.5,'MarkerSize',4);
xlabel('Angle of attack, \alpha (deg)'); ylabel('Flight velocity, V (m/s)');
title('Flight Velocity vs Angle of Attack'); grid on;
saveas(gcf, '06_V_vs_alpha.png');

figure('Name','Efficiency metrics');
plot(alpha_deg, LDratio, '-o','LineWidth',1.5,'MarkerSize',4); hold on;
plot(alpha_deg, L32D, '-s','LineWidth',1.5,'MarkerSize',4);
xlabel('Angle of attack, \alpha (deg)'); ylabel('Performance metric');
legend('C_L/C_D','C_L^{1.5}/C_D','Location','best');
title('Aerodynamic Efficiency Metrics vs Angle of Attack'); grid on;
saveas(gcf, '07_efficiency_metrics_vs_alpha.png');

fprintf('\nAll figures saved as PNG in the current folder.\n');
fprintf('Results table written to results_table.csv\n');
