function label = describe_idx(om, idx_type, idxs)
%DESCRIBE_IDX  Identifies variable, constraint and cost row indices.
%   LABEL = DESCRIBE_IDX(OM, IDX_TYPE, IDXS)
%
%   Returns strings describing (name and index) the variable, constraint
%   or cost row that corresponds to the indices in IDXS. IDX_TYPE must be
%   one of the following: 'var', 'lin', 'nln', or 'cost', corresponding
%   to indices for variables, linear constraints, non-linear constraints
%   and cost rows, respectively. The return value is a string if IDXS is
%   a scalar, otherwise it is a cell array of strings of the same
%   dimension as IDXS.
%
%   Examples:
%       label = describe_idx(om, 'var', 87));
%       labels = describe_idx(om, 'lin', [38; 49; 93]));
%   
%   See also OPT_MODEL.

%   MATPOWER
%   Copyright (c) 2012-2015 by Power System Engineering Research Center (PSERC)
%   by Ray Zimmerman, PSERC Cornell
%
%   $Id: describe_idx.m 2644 2015-03-11 19:34:22Z ray $
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See http://www.pserc.cornell.edu/matpower/ for more info.

label = cell(size(idxs));       %% pre-allocate return cell array
for i = 1:length(idxs(:))
    ii = idxs(i);
    if ii > om.(idx_type).N
        error('@opt_model/describe_idx: index exceeds maximum %s index (%d)', idx_type, om.(idx_type).N);
    end
    if ii < 1
        error('@opt_model/describe_idx: index must be positive');
    end
    for k = om.(idx_type).NS:-1:1
        name = om.(idx_type).order(k).name;
        idx = om.(idx_type).order(k).idx;
        if isempty(idx)
            if ii >= om.(idx_type).idx.i1.(name)
                label{i} = sprintf('%s(%d)', name, ii - om.(idx_type).idx.i1.(name) + 1);
                break;
            end
        else
            s = substruct('.', name, '()', idx);
            if ii >= subsref(om.(idx_type).idx.i1, s)
                idxstr = sprintf('%d', idx{1});
                for j = 2:length(idx)
                    idxstr = sprintf('%s,%d', idxstr, idx{j});
                end
                label{i} = sprintf('%s(%s)(%d)', name, idxstr, ...
                            ii - subsref(om.(idx_type).idx.i1, s) + 1);
                break;
            end
        end
    end
end
if isscalar(idxs)               %% return scalar
    label = label{1};
end
