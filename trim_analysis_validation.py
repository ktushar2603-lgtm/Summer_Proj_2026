"""
trim_analysis_validation.py
----------------------------
Python re-implementation of the MATLAB model (matlab/main_trim_analysis.m)
used ONLY to independently validate the numerical results before the
MATLAB code is run/submitted. Same equations, same inputs, same output
tables -> if both agree, the MATLAB code is verified correct.

Project: Trim, Thrust Required and Power Required Analysis of a
         Cropped Delta Wing UAV (Project Assignment 4)
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# ---------------------------------------------------------------
# 1. GIVEN DATA
# ---------------------------------------------------------------
Cr = 0.9          # root chord [m]
Ct = 0.15         # tip chord [m]
b  = 1.5          # span [m]
e  = 0.89         # Oswald efficiency factor

CD0    = 0.03     # zero-lift drag coefficient
Cm0    = 0.01     # zero-alpha, zero-elevator pitching moment coeff
CLalpha  = 2.92    # per rad
CLde     = 0.265   # per rad  (elevator/elevon lift effectiveness)
Cmalpha  = -0.292   # per rad
Cmde     = -0.4    # per rad  (elevator/elevon pitch effectiveness)
CL0      = 0.0     # NOT given in the assignment data -> assumed 0
                    # (reasonable for a reflexed tailless delta whose
                    # camber/twist is already captured by Cm0; state this
                    # assumption explicitly in the report)

mass = 3.5         # kg
rho  = 1.225       # kg/m^3 (sea level)
g    = 10          # m/s^2  (as specified in the assignment)

W = mass * g        # weight [N]

# ---------------------------------------------------------------
# 2. PREPROCESSING (GEOMETRY)
# ---------------------------------------------------------------
taper = Ct / Cr                       # taper ratio, lambda
S     = (b / 2) * Cr * (1 + taper)    # planform area [m^2]
AR    = b**2 / S                      # aspect ratio
k     = 1 / (np.pi * e * AR)          # induced drag factor

print("=== Geometry ===")
print(f"Taper ratio  lambda = {taper:.4f}")
print(f"Planform area   S   = {S:.4f} m^2")
print(f"Aspect ratio   AR   = {AR:.4f}")
print(f"Induced factor  k   = {k:.4f}")
print(f"Weight          W   = {W:.2f} N")
print()

# ---------------------------------------------------------------
# 3. ANGLE OF ATTACK SWEEP
# ---------------------------------------------------------------
alpha_deg = np.arange(0, 12 + 0.5, 0.5)     # 0 to 12 deg, step 0.5 deg
alpha_rad = np.deg2rad(alpha_deg)
n = len(alpha_deg)

de_trim   = np.zeros(n)   # trim elevator/elevon deflection [rad]
CL_trim   = np.zeros(n)
CD_trim   = np.zeros(n)
V         = np.zeros(n)
Tr        = np.zeros(n)
Pr        = np.zeros(n)
LDratio   = np.zeros(n)
L32D      = np.zeros(n)

for i in range(n):
    a = alpha_rad[i]

    # --- Trim condition: Cm = Cm0 + Cmalpha*a + Cmde*de = 0 ---
    de = -(Cm0 + Cmalpha * a) / Cmde
    de_trim[i] = de

    # --- Corresponding trim lift coefficient ---
    CL = CL0 + CLalpha * a + CLde * de
    CL_trim[i] = CL

    # --- Drag polar ---
    CD = CD0 + k * CL**2
    CD_trim[i] = CD

    # --- Level flight: L = W ---
    if CL > 0:
        Vi = np.sqrt(2 * W / (rho * S * CL))
    else:
        Vi = np.nan
    V[i] = Vi

    # --- Thrust required (D = T at level flight) ---
    Tr[i] = 0.5 * rho * Vi**2 * S * CD

    # --- Power required ---
    Pr[i] = Tr[i] * Vi

    # --- Performance metrics ---
    LDratio[i] = CL / CD
    L32D[i]    = CL**1.5 / CD

# ---------------------------------------------------------------
# 4. RESULTS TABLE
# ---------------------------------------------------------------
df = pd.DataFrame({
    "alpha_deg": alpha_deg,
    "de_trim_deg": np.rad2deg(de_trim),
    "CL_trim": CL_trim,
    "CD_trim": CD_trim,
    "V_m_s": V,
    "Tr_N": Tr,
    "Pr_W": Pr,
    "CL_CD": LDratio,
    "CL32_CD": L32D,
})

pd.set_option("display.float_format", lambda x: f"{x:0.4f}")
print("=== Results (first 10 rows) ===")
print(df.head(10).to_string(index=False))
print("...")

df.to_csv("/home/claude/project/python/results_table.csv", index=False)

# Key extrema for the report / discussion section
i_minTr = int(np.nanargmin(Tr))
i_minPr = int(np.nanargmin(Pr))
i_maxLD = int(np.nanargmax(LDratio))
i_maxL32D = int(np.nanargmax(L32D))

print("\n=== Key performance points ===")
print(f"Min Thrust required : {Tr[i_minTr]:.3f} N at alpha={alpha_deg[i_minTr]:.1f} deg, V={V[i_minTr]:.2f} m/s")
print(f"Min Power required   : {Pr[i_minPr]:.3f} W at alpha={alpha_deg[i_minPr]:.1f} deg, V={V[i_minPr]:.2f} m/s")
print(f"Max CL/CD (range,jet): {LDratio[i_maxLD]:.3f} at alpha={alpha_deg[i_maxLD]:.1f} deg")
print(f"Max CL^1.5/CD (endur): {L32D[i_maxL32D]:.3f} at alpha={alpha_deg[i_maxL32D]:.1f} deg")

# ---------------------------------------------------------------
# 5. PLOTS  (6 required plots)
# ---------------------------------------------------------------
plt.rcParams.update({"font.size": 11})
outdir = "/home/claude/project/plots"

def make_plot(x, y, xlabel, ylabel, title, fname, xdeg=True):
    fig, ax = plt.subplots(figsize=(6, 4.2))
    ax.plot(x, y, marker="o", markersize=3, linewidth=1.6, color="#1f77b4")
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.grid(True, linewidth=0.4, alpha=0.7)
    fig.tight_layout()
    fig.savefig(f"{outdir}/{fname}", dpi=160)
    plt.close(fig)

make_plot(alpha_deg, np.rad2deg(de_trim), "Angle of attack, alpha (deg)",
           "Trim elevon deflection, delta_e (deg)",
           "Trim Elevon Deflection vs Angle of Attack", "01_de_trim_vs_alpha.png")

make_plot(alpha_deg, CL_trim, "Angle of attack, alpha (deg)", "Lift coefficient, CL",
           "Trim Lift Coefficient vs Angle of Attack", "02_CL_vs_alpha.png")

make_plot(alpha_deg, CD_trim, "Angle of attack, alpha (deg)", "Drag coefficient, CD",
           "Drag Coefficient vs Angle of Attack", "03_CD_vs_alpha.png")

make_plot(V, Tr, "Flight velocity, V (m/s)", "Thrust required, Tr (N)",
           "Thrust Required vs Flight Velocity", "04_Tr_vs_V.png")

make_plot(V, Pr, "Flight velocity, V (m/s)", "Power required, Pr (W)",
           "Power Required vs Flight Velocity", "05_Pr_vs_V.png")

make_plot(alpha_deg, V, "Angle of attack, alpha (deg)", "Flight velocity, V (m/s)",
           "Flight Velocity vs Angle of Attack", "06_V_vs_alpha.png")

# Bonus: performance metrics plot (supports Phase 2 discussion)
fig, ax = plt.subplots(figsize=(6, 4.2))
ax.plot(alpha_deg, LDratio, marker="o", markersize=3, label="CL/CD")
ax.plot(alpha_deg, L32D, marker="s", markersize=3, label="CL^1.5/CD")
ax.set_xlabel("Angle of attack, alpha (deg)")
ax.set_ylabel("Performance metric")
ax.set_title("Aerodynamic Efficiency Metrics vs Angle of Attack")
ax.grid(True, linewidth=0.4, alpha=0.7)
ax.legend()
fig.tight_layout()
fig.savefig(f"{outdir}/07_efficiency_metrics_vs_alpha.png", dpi=160)
plt.close(fig)

print("\nAll plots saved to:", outdir)
print("Results table saved to: /home/claude/project/python/results_table.csv")
