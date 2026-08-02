function geom = compute_geometry(geom)
%COMPUTE_GEOMETRY  Preprocessing geometric parameters for a cropped
%   (straight-tapered) delta wing, given root chord, tip chord, span
%   and Oswald efficiency factor.
%
%   geom = compute_geometry(geom) expects fields geom.Cr, geom.Ct,
%   geom.b, geom.e and returns geom with added fields:
%       lambda  - taper ratio            (Ct/Cr)
%       S       - planform area          [m^2]
%       AR      - aspect ratio           (b^2/S)
%       k       - induced drag factor    1/(pi*e*AR)

    geom.lambda = geom.Ct / geom.Cr;
    geom.S      = (geom.b/2) * geom.Cr * (1 + geom.lambda);
    geom.AR     = geom.b^2 / geom.S;
    geom.k      = 1 / (pi * geom.e * geom.AR);
end
