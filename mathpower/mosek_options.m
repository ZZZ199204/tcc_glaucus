function opt = mosek_options(overrides, mpopt)
%MOSEK_OPTIONS  Sets options for MOSEK.
%
%   OPT = MOSEK_OPTIONS
%   OPT = MOSEK_OPTIONS(OVERRIDES)
%   OPT = MOSEK_OPTIONS(OVERRIDES, FNAME)
%   OPT = MOSEK_OPTIONS(OVERRIDES, MPOPT)
%
%   Sets the values for the param struct normally passed to MOSEKOPT.
%
%   Inputs are all optional, second argument must be either a string
%   (FNAME) or a struct (MPOPT):
%
%       OVERRIDES - struct containing values to override the defaults
%       FNAME - name of user-supplied function called after default
%           options are set to modify them. Calling syntax is:
%                   MODIFIED_OPT = FNAME(DEFAULT_OPT);
%       MPOPT - MATPOWER options struct, uses the following fields:
%           opf.violation   - used to set opt.MSK_DPAR_INTPNT_TOL_PFEAS
%           verbose         - not currently used here
%           mosek.lp_alg    - used to set opt.MSK_IPAR_OPTIMIZER
%           mosek.max_it    - used to set opt.MSK_IPAR_INTPNT_MAX_ITERATIONS
%           mosek.gap_tol   - used to set opt.MSK_DPAR_INTPNT_TOL_REL_GAP
%           mosek.max_time  - used to set opt.MSK_DPAR_OPTIMIZER_MAX_TIME
%           mosek.num_threads - used to set opt.MSK_IPAR_INTPNT_NUM_THREADS
%           mosek.opts      - struct containing values to use as OVERRIDES
%           mosek.opt_fname - name of user-supplied function used as FNAME,
%               except with calling syntax:
%                   MODIFIED_OPT = FNAME(DEFAULT_OPT, MPOPT);
%           mosek.opt       - numbered user option function, if and only if
%               mosek.opt_fname is empty and mosek.opt is non-zero, the value
%               of mosek.opt_fname is generated by appending mosek.opt to
%               'mosek_user_options_' (for backward compatibility with old
%               MATPOWER option MOSEK_OPT).
%
%   Output is a param struct to pass to MOSEKOPT.
%
%   There are multiple ways of providing values to override the default
%   options. Their precedence and order of application are as follows:
%
%   With inputs OVERRIDES and FNAME
%       1. FNAME is called
%       2. OVERRIDES are applied
%   With inputs OVERRIDES and MPOPT
%       1. FNAME (from mosek.opt_fname or mosek.opt) is called
%       2. mosek.opts (if not empty) are applied
%       3. OVERRIDES are applied
%
%   Example:
%
%   If mosek.opt = 3, then after setting the default MOSEK options,
%   MOSEK_OPTIONS will execute the following user-defined function
%   to allow option overrides:
%
%       opt = mosek_user_options_3(opt, mpopt);
%
%   The contents of mosek_user_options_3.m, could be something like:
%
%       function opt = mosek_user_options_3(opt, mpopt)
%       opt.MSK_DPAR_INTPNT_TOL_DFEAS   = 1e-9;
%       opt.MSK_IPAR_SIM_MAX_ITERATIONS = 5000000;
%
%   See the Parameters reference in "The MOSEK optimization toolbox
%   for MATLAB manaul" for details on the available options. You may also
%   want to use the symbolic constants defined by MOSEK_SYMBCON.
%
%       http://docs.mosek.com/7.1/toolbox/Parameters.html
%
%   See also MOSEK_SYMBCON, MOSEKOPT, MPOPTION.

%   MATPOWER
%   Copyright (c) 2010-2015 by Power System Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   $Id: mosek_options.m 2644 2015-03-11 19:34:22Z ray $
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See http://www.pserc.cornell.edu/matpower/ for more info.

%%-----  initialization and arg handling  -----
%% defaults
verbose = 2;
gaptol  = 0;
fname   = '';

%% get symbolic constant names
sc = mosek_symbcon;

%% second argument
if nargin > 1 && ~isempty(mpopt)
    if ischar(mpopt)        %% 2nd arg is FNAME (string)
        fname = mpopt;
        have_mpopt = 0;
    else                    %% 2nd arg is MPOPT (MATPOWER options struct)
        have_mpopt = 1;
        verbose = mpopt.verbose;
        if isfield(mpopt.mosek, 'opt_fname') && ~isempty(mpopt.mosek.opt_fname)
            fname = mpopt.mosek.opt_fname;
        elseif mpopt.mosek.opt
            fname = sprintf('mosek_user_options_%d', mpopt.mosek.opt);
        end
    end
else
    have_mpopt = 0;
end

%%-----  set default options for MOSEK  -----
%% solution algorithm
if have_mpopt
    alg = mpopt.mosek.lp_alg;
    switch alg                                          %% v6.x v7.x
        case {  sc.MSK_OPTIMIZER_FREE,                  %%  0    0
                sc.MSK_OPTIMIZER_INTPNT,                %%  1    1
                sc.MSK_OPTIMIZER_PRIMAL_SIMPLEX,        %%  4    3
                sc.MSK_OPTIMIZER_DUAL_SIMPLEX,          %%  5    4
                sc.MSK_OPTIMIZER_PRIMAL_DUAL_SIMPLEX,   %%  6    5
                sc.MSK_OPTIMIZER_FREE_SIMPLEX,          %%  7    6
%                 sc.MSK_OPTIMIZER_NETWORK_PRIMAL_SIMPLEX,%%  -    7 (non-existent for MOSEK v6)
                sc.MSK_OPTIMIZER_CONCURRENT }           %% 10   10
            opt.MSK_IPAR_OPTIMIZER = alg;
        otherwise
            if have_fcn('mosek', 'vnum') >= 7 && ...
                    alg == sc.MSK_OPTIMIZER_NETWORK_PRIMAL_SIMPLEX
                opt.MSK_IPAR_OPTIMIZER = alg;
            else
                opt.MSK_IPAR_OPTIMIZER = sc.MSK_OPTIMIZER_FREE;
            end
    end

    %% (make default opf.violation correspond to default MSK_DPAR_INTPNT_TOL_PFEAS)
    opt.MSK_DPAR_INTPNT_TOL_PFEAS = mpopt.opf.violation/500;
    if mpopt.mosek.max_it
        opt.MSK_IPAR_INTPNT_MAX_ITERATIONS = mpopt.mosek.max_it;
    end
    if mpopt.mosek.gap_tol
        opt.MSK_DPAR_INTPNT_TOL_REL_GAP = mpopt.mosek.gap_tol;
    end
    if mpopt.mosek.max_time
        opt.MSK_DPAR_OPTIMIZER_MAX_TIME = mpopt.mosek.max_time;
    end
    if mpopt.mosek.num_threads
        if have_fcn('mosek', 'vnum') < 7
            opt.MSK_IPAR_INTPNT_NUM_THREADS = mpopt.mosek.num_threads;
        else
            opt.MSK_IPAR_NUM_THREADS = mpopt.mosek.num_threads;
        end
    end
else
    opt.MSK_IPAR_OPTIMIZER = sc.MSK_OPTIMIZER_FREE;
end
% opt.MSK_DPAR_INTPNT_TOL_PFEAS = 1e-8;       %% primal feasibility tol
% opt.MSK_DPAR_INTPNT_TOL_DFEAS = 1e-8;       %% dual feasibility tol
% opt.MSK_DPAR_INTPNT_TOL_MU_RED = 1e-16;     %% relative complementarity gap tol
% opt.MSK_DPAR_INTPNT_TOL_REL_GAP = 1e-8;     %% relative gap termination tol
% opt.MSK_IPAR_INTPNT_MAX_ITERATIONS = 400;   %% max iterations for int point
% opt.MSK_IPAR_SIM_MAX_ITERATIONS = 10000000; %% max iterations for simplex
% opt.MSK_DPAR_OPTIMIZER_MAX_TIME = -1;       %% max time allowed (< 0 --> Inf)
% opt.MSK_IPAR_INTPNT_NUM_THREADS = 1;        %% number of threads
% opt.MSK_IPAR_PRESOLVE_USE = sc.MSK_PRESOLVE_MODE_OFF;

% if verbose == 0
%     opt.MSK_IPAR_LOG = 0;
% end

%%-----  call user function to modify defaults  -----
if ~isempty(fname)
    if have_mpopt
        opt = feval(fname, opt, mpopt);
    else
        opt = feval(fname, opt);
    end
end

%%-----  apply overrides  -----
if have_mpopt && isfield(mpopt.mosek, 'opts') && ~isempty(mpopt.mosek.opts)
    opt = nested_struct_copy(opt, mpopt.mosek.opts);
end
if nargin > 0 && ~isempty(overrides)
    opt = nested_struct_copy(opt, overrides);
end
