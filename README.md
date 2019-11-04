# On-the-Reliability-of-Cancelable-Biometrics-Revisit-the-Irreversibility

# Usage based on BioHashing example

# Fitness function
fitness_biohashing.m
```bash
function [distance] = fitness_biohashing(x, hashcode,opts)


[transformed_data] = biohashing(x,opts.model);

% [distance] = bloomfilter_hamming(transformed_data0,hashcode,opts); %
% original distance
distcc=[];
for a=1:size(hashcode,1)
    distcc=[distcc 1 - matching_IoM(hashcode(a,:),transformed_data)];
end

distance=mean(distcc);


end
```

In the above code, the hashcode can be multiple templates, the fitness function will compute the fitness based on averaging

# GA reconstruct set up
reconstruct.m

```bash
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
```
# Launch the attack
SA_BioHashing_multiple.m

```bash
 for jjj=1:5
        %% reconstruct the first one
        for i=1:158
            
            disp(['reconstructing ',num2str(i)])
            to_retrieve_hash=transformed_data((i-1)*10+1:1:(i-1)*10+jjj,:); % first of the template are used to reconstruct
            %rng default % For reproducibility
            f_fitness = @(x)fitness_biohashing(x,to_retrieve_hash,opts); % fitness function
            f_constr = []; % constrain function
            reconstruct_x(i,:) = reconstruct(f_fitness,f_constr,opts);
            
        end
         save(['data/biohashing/20190620biohashing_reconstruct_',num2str(hamming_dimension),'_',num2str(jjj),'.mat'],'reconstruct_x');
         save(['data/biohashing/20190620biohashing_eer_',num2str(hamming_dimension),'_',num2str(jjj),'.mat'],'EER_HASH');
    end
```
jjj indicates how many templates are compromised and are used to reconstruct the feature vector.





