function [x] = reconstruct_bloom(f_fitness,f_constr,opts)
%RECONSTRUCT Summary of this function goes here
%   Detailed explanation goes here


%rng default % For reproducibility
%f_fitness = @(x)fitness(x,protected_template,opts); % fitness function
%f_constr = @(x)constraintsofx(x,protected_template,opts); % constrain function
A = [];
b = [];
Aeq = [];
beq = [];
% lb = ones(1,opts.H*opts.W)*0;
% ub = ones(1,opts.H*opts.W)*1; % upper bound
% IntCon = [1:20*480];


options = optimoptions('ga','ConstraintTolerance',1e-6,'FunctionTolerance',1e-6,...
    'PlotFcn', {@gaplotbestf2, @gaplotscores},'MaxGenerations',1500,'MaxTime',Inf,...
    'CrossoverFraction',0.9,'UseParallel',false,'PopulationType','bitstring','PopulationSize',300);

% options = optimoptions('ga','ConstraintTolerance',1e-6,'FunctionTolerance',1e-6,...
%     'MaxGenerations',1000,'MaxTime',Inf,...
%     'CrossoverFraction',0.9,'UseParallel',false,'PopulationType','bitstring','PopulationSize',300);

% options = optimoptions('ga','ConstraintTolerance',1e-6,'FunctionTolerance',1e-10,...
%     'MaxGenerations',1000,'MaxTime',Inf,...
%     'CrossoverFraction',0.9,'UseParallel',true,'PopulationType','bitstring','PopulationSize',100);

% options = optimoptions('ga','ConstraintTolerance',1e-6,'FunctionTolerance',1e-10,...
%     'MaxGenerations',500,'MaxTime',Inf,'CrossoverFraction',0.9,'UseParallel',true);

tic
[x,fval,exitflag,output] = ga(f_fitness,opts.H*opts.W,A,b,Aeq,beq,[],[],f_constr,options);
toc


end

