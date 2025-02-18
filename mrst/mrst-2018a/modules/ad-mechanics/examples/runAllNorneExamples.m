%% Example: Simulation of poroelasticity on a subset of the Norne case
% 
% Same setting as in runAll2Dcases but now for a subset of the Norne
% case
%
% See: runNorneExample and setupNorneExamples
%


mrstModule add ad-mechanics ad-core ad-props ad-blackoil vemmech deckformat mrst-gui

%% Summary of the options

% opt.norne_case = 'mini Norne'; % 'full' or 'mini Norne'
%
% 'full'       : 7392 cells
% 'mini Norne' :  605 cells
%
% opt.bc_case    = 'bottom fixed'; % 'no displacement' or 'bottom fixed'
%
% 'no displacement' : All nodes belonging to external faces have displacement
%                     equal to zero
% 'bottom fixed'    : The nodes that belong to the bottom have zero
%                     displacement, while a given pressure is imposed on
%                     the external faces that are not bottom faces.
%
% opt.method     = 'fully coupled'; % 'fully coupled' 'fixed stress splitting'
%
% 'fully coupled'          : The mechanical and flow equations are solved fully couplde.
%
% 'fixed stress splitting' : The mechanical and flow equations are solved
%                            sequentially using a fixed stress splitting
%
% opt.fluid_model = 'oil water'; % 'blackoil' 'water' 'oil water'
%
% 'blackoil'     : blackoil model is used for the fluid (gas is injected, see
%                  schedule below)
% 'oil water'    : Two phase oil-water
% 'water' : water model is used for the fluid

clear opt
opt.verbose          = false;
opt.splittingVerbose = false;
opt.norne_case       = 'mini Norne';
opt.bc_case          = 'bottom fixed';

% write intro text for each case
writeIntroText = @(opt)(fprintf('\n*** Start new simulation\n* fluid model : %s\n* method : %s\n\n', opt.fluid_model, opt.method));

%%  water cases

opt.fluid_model = 'water';

opt.method = 'fully coupled';
writeIntroText(opt);
optvals = cellfun(@(x) opt.(x), fieldnames(opt), 'uniformoutput', false);
optlist = reshape(vertcat(fieldnames(opt)', optvals'), [], 1);
[model, states] = runNorneExample(optlist{:});
plotNornePoroExample(model, states, opt);

opt.method = 'fixed stress splitting';
writeIntroText(opt);
optvals = cellfun(@(x) opt.(x), fieldnames(opt), 'uniformoutput', false);
optlist = reshape(vertcat(fieldnames(opt)', optvals'), [], 1);
[model, states] = runNorneExample(optlist{:});
plotNornePoroExample(model, states, opt);


%%  Two phase oil water phases cases

opt.fluid_model = 'oil water';

opt.method = 'fully coupled';
writeIntroText(opt);
optvals = cellfun(@(x) opt.(x), fieldnames(opt), 'uniformoutput', false);
optlist = reshape(vertcat(fieldnames(opt)', optvals'), [], 1);
[model, states] = runNorneExample(optlist{:});
plotNornePoroExample(model, states, opt);

opt.method = 'fixed stress splitting';
writeIntroText(opt);
optvals = cellfun(@(x) opt.(x), fieldnames(opt), 'uniformoutput', false);
optlist = reshape(vertcat(fieldnames(opt)', optvals'), [], 1);
[model, states] = runNorneExample(optlist{:});
plotNornePoroExample(model, states, opt);


%%  Three phases Black-Oil phases cases

opt.fluid_model = 'blackoil';

opt.method = 'fully coupled';
writeIntroText(opt);
optvals = cellfun(@(x) opt.(x), fieldnames(opt), 'uniformoutput', false);
optlist = reshape(vertcat(fieldnames(opt)', optvals'), [], 1);
[model, states] = runNorneExample(optlist{:});
plotNornePoroExample(model, states, opt);

opt.method = 'fixed stress splitting';
writeIntroText(opt);
opt.splittingTolerance = 1e-3;
optvals = cellfun(@(x) opt.(x), fieldnames(opt), 'uniformoutput', false);
optlist = reshape(vertcat(fieldnames(opt)', optvals'), [], 1);
[model, states] = runNorneExample(optlist{:});
plotNornePoroExample(model, states, opt);
