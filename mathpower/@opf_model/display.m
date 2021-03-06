function display(om)
%DISPLAY  Displays the object.
%   Called when semicolon is omitted at the command-line. Displays the details
%   of the variables, constraints, costs included in the model.
%
%   See also OPT_MODEL.

%   MATPOWER
%   Copyright (c) 2008-2015 by Power System Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   $Id: display.m 2644 2015-03-11 19:34:22Z ray $
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See http://www.pserc.cornell.edu/matpower/ for more info.

display(om.opt_model)

fprintf('  mpc = ');
if ~isempty(fieldnames(om.mpc))
    fprintf('\n');
end
if have_fcn('octave')
    fprintf('    <scalar struct>\n');
else
    display(om.mpc);
end
