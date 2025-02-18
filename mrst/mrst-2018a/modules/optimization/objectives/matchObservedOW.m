function obj = matchObservedOW(G, wellSols, schedule, observed, varargin)
% Compute mismatch-function 

%{
Copyright 2009-2018 SINTEF ICT, Applied Mathematics.

This file is part of The MATLAB Reservoir Simulation Toolbox (MRST).

MRST is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MRST is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MRST.  If not, see <http://www.gnu.org/licenses/>.
%}
opt     = struct('WaterRateWeight',     [] , ...
                 'OilRateWeight',       [] , ...
                 'BHPWeight',           [] , ...
                 'ComputePartials',     false, ...
                 'tStep' ,              [], ...
                 'matchOnlyProducers',  false);
             
opt     = merge_options(opt, varargin{:});


% pressure and saturaton vectors just used for place-holding
p  = zeros(G.cells.num, 1);
sW = zeros(G.cells.num, 1);

dts   = schedule.step.val;
totTime = sum(dts);

tSteps = opt.tStep;
if isempty(tSteps) %do all
    numSteps = numel(dts);
    tSteps = (1:numSteps)';
else
    numSteps = 1;
    dts = dts(opt.tStep);
end


obj = repmat({[]}, numSteps, 1);

for step = 1:numSteps
    sol = wellSols{tSteps(step)};
    [qWs, qOs, bhp] = deal(vertcat(sol.qWs), vertcat(sol.qOs), vertcat(sol.bhp) );
    nw = numel(bhp);
    sol_obs = observed{tSteps(step)};
    [qWs_obs, qOs_obs, bhp_obs] = deal( vertcatIfPresent(sol_obs, 'qWs', nw), ...
                                        vertcatIfPresent(sol_obs, 'qOs', nw), ...
                                        vertcatIfPresent(sol_obs, 'bhp', nw) );

    if opt.matchOnlyProducers
        matchCases = (vertcat(sol.sign) < 0);
    else
        matchCases = true(nw,1);
    end
    %display(class(qWs_obs));
    %display(class(qWs));
    [ww, wo, wp] = getWeights_noise(qWs_obs, qOs_obs, bhp_obs, opt);
    
     if opt.ComputePartials
         [~, ~, qWs, qOs, bhp] = ...
           initVariablesADI(p, sW, qWs, qOs, bhp);                    
     end
    
    dt = dts(step);
    %display(class(qWs_obs));
    %display(class(qWs));
    %display(class(qOs_obs));
    %display(class(qOs));
    obj{step} = (dt/(totTime*nnz(matchCases)^2))*sum( ...
                                (ww.*matchCases.*(qWs-double(qWs_obs))).^2 + ...
                                (wo.*matchCases.*(qOs-double(qOs_obs))).^2 + ...
                                (wp.*matchCases.*(bhp-double(bhp_obs))).^2 );
end
end

%--------------------------------------------------------------------------

function v = vertcatIfPresent(sol, fn, nw)
if isfield(sol, fn)
    v = vertcat(sol.(fn));
    assert(numel(v)==nw);
else
    v = zeros(nw,1);
end
end

%--------------------------------------------------------------------------
% function  [ww, wo, wp] = getWeights(qWs, qOs, bhp, opt)
% ww = opt.WaterRateWeight;
% wo = opt.OilRateWeight;
% wp = opt.BHPWeight;   

% ww = (qWs+1e-8).^(-2);
% wo = (qOs+1e-8).^(-2);
% wp = (bhp+1e-8).^(-2);

% end
function  [ww, wo, wp] = getWeights(qWs, qOs, bhp, opt)
ww = opt.WaterRateWeight;
wo = opt.OilRateWeight;
wp = opt.BHPWeight;

rw = sum(abs(qWs)+abs(qOs));

if isempty(ww)
    % set to zero if all are zero
    if sum(abs(qWs))==0
        ww = 0;
    else
        ww = 1/rw;
    end
end

if isempty(wo)
    % set to zero if all are zero
    if sum(abs(qOs))==0
        wo = 0;
    else
        wo = 1/rw;
    end
end

if isempty(wp)
    % set to zero all are same
    dp = max(bhp)-min(bhp);
    if dp == 0
        wp = 0;
    else
        wp = 1/dp;
    end
end
end

function  [ww, wo, wp] = getWeights_noise(qWs, qOs, bhp, opt)
    ww = opt.WaterRateWeight;
    wo = opt.OilRateWeight;
    wp = opt.BHPWeight;
    
    %rw = sum(abs(qWs)+abs(qOs));
    %display(class(rw));
    rw = double(0.03*300.0/(60.0*60.0*24.0));%sum(abs(qWs)+abs(qOs));
    %display(class(rw));
    if isempty(ww)
        % set to zero if all are zero
        if sum(abs(qWs))==0
            ww = 0;
        else
            ww = 1.0/rw;
        end
    end
    
    if isempty(wo)
        % set to zero if all are zero
        if sum(abs(qOs))==0
            wo = 0;
        else
            wo = 1.0/rw;
        end
    end
    
    if isempty(wp)
        % set to zero all are same
        %dp = max(bhp)-min(bhp);
        %display(class(dp));
        dp =  double(0.0001*200.0e7);
        %display(class(dp));
        if dp == 0
            wp = 0;
        else
            wp = 1.0/dp;
        end
    end
    end


