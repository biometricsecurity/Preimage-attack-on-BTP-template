function [x] = reconstruct(f_fitness,f_constr,opts)
%RECONSTRUCT Summary of this function goes here
%   Detailed explanation goes here


%rng default % For reproducibility
%f_fitness = @(x)fitness(x,protected_template,opts); % fitness function
%f_constr = @(x)constraintsofx(x,protected_template,opts); % constrain function

A = [];
b = [];
Aeq = [];
beq = [];
lb = ones(1,opts.dX)*-1;
ub = ones(1,opts.dX)*1; % upper bound

%    %'PlotFcn', @gaplotbestf,...  'PlotFcn', {@gaplotbestf, @gaplotscores},

options = optimoptions('ga','ConstraintTolerance',1e-6,'FunctionTolerance',1e-10,...
    'MaxGenerations',200,'MaxTime',Inf,'CrossoverFraction',0.9,'UseParallel',true);
tic
[x,fval,exitflag,output] = ga(f_fitness,opts.dX,A,b,Aeq,beq,lb,ub,f_constr,options);
toc

end

