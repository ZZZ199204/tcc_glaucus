function [Avl, lvl, uvl, ivl]  = makeAvl(baseMVA, gen)
%MAKEAVL Construct linear constraints for constant power factor var loads.
%   [AVL, LVL, UVL, IVL]  = MAKEAVL(BASEMVA, GEN)
%
%   Constructs parameters for the following linear constraint enforcing a
%   constant power factor constraint for dispatchable loads.
%
%        LVL <= AVL * [Pg; Qg] <= UVL
%
%   IVL is the vector of indices of generators representing variable loads.
%
%   Example:
%       [Avl, lvl, uvl, ivl]  = makeAvl(baseMVA, gen);

%   MATPOWER
%   Copyright (c) 1996-2015 by Power System Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%   and Carlos E. Murillo-Sanchez, PSERC Cornell & Universidad Autonoma de Manizales
%
%   $Id: makeAvl.m 2644 2015-03-11 19:34:22Z ray $
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See http://www.pserc.cornell.edu/matpower/ for more info.

%% define named indices into data matrices
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

%% data dimensions
ng = size(gen, 1);      %% number of dispatchable injections
Pg   = gen(:, PG) / baseMVA;
Qg   = gen(:, QG) / baseMVA;
Pmin = gen(:, PMIN) / baseMVA;
Qmin = gen(:, QMIN) / baseMVA;
Qmax = gen(:, QMAX) / baseMVA;


% Find out if any of these "generators" are actually dispatchable loads.
% (see 'help isload' for details on what constitutes a dispatchable load)
% Dispatchable loads are modeled as generators with an added constant
% power factor constraint. The power factor is derived from the original
% value of Pmin and either Qmin (for inductive loads) or Qmax (for capacitive
% loads). If both Qmin and Qmax are zero, this implies a unity power factor
% without the need for an additional constraint.


ivl = find( isload(gen) & (Qmin ~= 0 | Qmax ~= 0) );
nvl  = size(ivl, 1);  %% number of dispatchable loads

%% at least one of the Q limits must be zero (corresponding to Pmax == 0)
if any( Qmin(ivl) ~= 0 & Qmax(ivl) ~= 0 )
    error('makeAvl: either Qmin or Qmax must be equal to zero for each dispatchable load.');
end

% Initial values of PG and QG must be consistent with specified power factor
% This is to prevent a user from unknowingly using a case file which would
% have defined a different power factor constraint under a previous version
% which used PG and QG to define the power factor.
Qlim = (Qmin(ivl) == 0) .* Qmax(ivl) + ...
    (Qmax(ivl) == 0) .* Qmin(ivl);
if any( abs( Qg(ivl) - Pg(ivl) .* Qlim ./ Pmin(ivl) ) > 1e-6 )
    error('makeAvl: %s\n         %s\n', ...
        'For a dispatchable load, PG and QG must be consistent', ...
        'with the power factor defined by PMIN and the Q limits.');
end

% make Avl, lvl, uvl, for lvl <= Avl * [Pg; Qg] <= uvl
if nvl > 0
  xx = Pmin(ivl);
  yy = Qlim;
  pftheta = atan2(yy, xx);
  pc = sin(pftheta);
  qc = -cos(pftheta);
  ii = [ (1:nvl)'; (1:nvl)' ];
  jj = [ ivl; ivl+ng ];
  Avl = sparse(ii, jj, [pc; qc], nvl, 2*ng);
  lvl = zeros(nvl, 1);
  uvl = lvl;
else
  Avl = sparse(0, 2*ng);
  lvl =[];
  uvl =[];
end
