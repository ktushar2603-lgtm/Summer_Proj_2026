# Trim, Thrust Required, and Power Required Analysis of a Cropped Delta Wing UAV

A MATLAB (with independent Python cross-validation) analysis of the trim, thrust-required, and power-required characteristics of a tailless, cropped delta wing UAV in steady, level flight, swept over angle of attack α = 0°–12°.

## Overview

This project computes, for a tailless cropped-delta-wing UAV trimmed directly by elevon deflection:

- Trim elevon deflection (δe,trim)
- Trim lift coefficient (CL,trim) and drag coefficient (CD,trim)
- Flight velocity, thrust required, and power required for steady level flight
- Aerodynamic efficiency metrics: CL/CD (range) and CL^1.5/CD (endurance)

at 0.5° increments of α from 0° to 12° (25 points), using a closed-form trim solution combined with a parabolic drag polar and the level-flight lift-equilibrium condition.

## Why a Tailless UAV Is Different

A cropped delta wing UAV has no separate horizontal tail, so the elevons that trim the aircraft are the same surfaces that generate lift. This couples the trim condition, lift, and drag together, meaning thrust and power required can't be expressed as a simple closed-form function of α alone — hence the numerical, angle-of-attack-swept approach used here.

## Aircraft & Aerodynamic Data

| Parameter | Symbol | Value |
|---|---|---|
| Root chord | Cr | 0.9 m |
| Tip chord | Ct | 0.15 m |
| Span | b | 1.5 m |
| Oswald efficiency factor | e | 0.89 |
| Zero-lift drag coefficient | CD0 | 0.03 |
| Zero-α, zero-δe pitching moment | Cm0 | 0.01 |
| Lift-curve slope | CLα | 2.92 /rad |
| Elevon lift effectiveness | CLδe | 0.265 /rad |
| Pitch stiffness derivative | Cmα | −0.292 /rad |
| Elevon pitch effectiveness | Cmδe | −0.4 /rad |
| Zero-α, zero-δe lift coefficient (assumed) | CL0 | 0 |
| Mass | m | 3.5 kg |
| Air density (sea level) | ρ | 1.225 kg/m³ |
| Gravitational acceleration | g | 10 m/s² |

> **Note:** CL0 was not specified in the original problem and is assumed to be 0, consistent with a reflexed camber implied by the given non-zero Cm0.

## Methodology

1. **Geometry** — taper ratio λ = Ct/Cr, planform area S = (b/2)·Cr·(1+λ), aspect ratio AR = b²/S, induced-drag factor k = 1/(π·e·AR).
2. **Trim** — solved in closed form from the moment-equilibrium equation:
   δe,trim = −(Cm0 + Cmα·α) / Cmδe, then CL,trim = CL0 + CLα·α + CLδe·δe,trim
3. **Drag polar** — CD = CD0 + k·CL²
4. **Level flight** — V = √(2W / (ρ·S·CL)), Tr = D = ½·ρ·V²·S·CD, Pr = Tr·V
5. **Efficiency metrics** — CL/CD (range-relevant) and CL^1.5/CD (endurance-relevant)

## Repository Structure

```
.
├── main_trim_analysis.m          # Driver script: sweeps α, calls the modules below,
│                                  # builds the results table, generates all plots
├── compute_geometry.m            # λ, S, AR, k from root chord, tip chord, span, e
├── trim_solve.m                  # δe,trim and CL,trim from α and the aero derivatives
├── level_flight_perf.m           # CD, V, Tr, Pr from CL,trim, geometry, and flight data
├── trim_analysis_validation.py   # Independent Python re-implementation for cross-check
├── results_table.csv             # Output: 25-row table of all computed quantities
└── plots/                        # Output: labelled PNG plots (see below)
```

## Requirements

- MATLAB (tested with a standard installation; no additional toolboxes required)
- Python 3 with NumPy/Pandas (only needed to run the independent validation script)

## Usage

```matlab
% From the MATLAB command window, in the project directory:
main_trim_analysis
```

This runs the full α = 0°–12° sweep, writes `results_table.csv`, prints the α at which
thrust/power required are minimized and CL/CD, CL^1.5/CD are maximized, and saves all
plots as PNG files.

To independently verify the MATLAB results:

```bash
python trim_analysis_validation.py
```

The Python output is compared row-by-row against `results_table.csv` and agrees to
floating-point precision across all 25 α points and all nine computed quantities.

## Results Summary

| Quantity | Value | At α |
|---|---|---|
| Minimum thrust required | 4.29 N | 10.0° |
| Corresponding velocity | 12.26 m/s | 10.0° |
| Maximum CL/CD | 8.16 | 10.0° |
| Maximum CL^1.5/CD (within tested range) | 6.12 (still rising) | 12.0° |
| Minimum power required (within tested range) | 48.7 W (still falling) | 12.0° |

**Key trends:**
- Trim elevon deflection falls from +1.43° (α=0°) to −7.33° (α=12°), crossing zero near α≈2°.
- Trim CL rises ~linearly with α, from 0.0066 to 0.578.
- Flight velocity, thrust, and power required are all unrealistically high near α=0° (V≈104.7 m/s, Tr≈158.5 N, Pr≈16,590 W) due to the very low trim CL there, and fall sharply as α increases.
- Thrust required is minimized at α≈10°; power required is still decreasing at α=12°, indicating the true minimum-power condition lies beyond the tested range.
- The endurance-optimal angle of attack (based on CL^1.5/CD) also lies beyond 12° and would require extending the sweep to identify.

## Generated Plots

- Trim elevon deflection vs. angle of attack
- Trim lift coefficient vs. angle of attack
- Drag coefficient vs. angle of attack
- Thrust required vs. flight velocity
- Power required vs. flight velocity
- Flight velocity vs. angle of attack
- Aerodynamic efficiency metrics (CL/CD and CL^1.5/CD) vs. angle of attack

## Author

Tushar Kumar — B.Tech. (ECE), Birla Institute of Technology, Mesra, Patna Campus
MC300 – Summer Training Project, under the guidance of Dr. Naren Das, Assistant Professor

## References

1. Anderson, J. D., *Aircraft Performance and Design*, McGraw-Hill, 1999.
2. Anderson, J. D., *Introduction to Flight*, 8th ed., McGraw-Hill Education, 2016.
3. Nelson, R. C., *Flight Stability and Automatic Control*, 2nd ed., McGraw-Hill, 1998.
4. Etkin, B. and Reid, L. D., *Dynamics of Flight: Stability and Control*, 3rd ed., Wiley, 1996.
5. Raymer, D. P., *Aircraft Design: A Conceptual Approach*, 6th ed., AIAA Education Series, 2018.
6. Phillips, W. F., *Mechanics of Flight*, 2nd ed., Wiley, 2010.
7. McCormick, B. W., *Aerodynamics, Aeronautics, and Flight Mechanics*, 2nd ed., Wiley, 1995.
8. Austin, R., *Unmanned Aircraft Systems: UAVs Design, Development and Deployment*, Wiley, 2010.
9. Gudmundsson, S., *General Aviation Aircraft Design: Applied Methods and Procedures*, Butterworth-Heinemann, 2014.
10. MathWorks, *MATLAB Documentation: table, writetable, and Data Types*, The MathWorks, Inc.
