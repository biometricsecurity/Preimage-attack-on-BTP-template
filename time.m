clear all;
close all;
load('data/lfw/LFW_10Samples_insightface.mat')
load('data/lfw/LFW_label_10Samples_insightface.mat')

addpath('matlab_tools');
addpath_recurse('btp')

hamming_dimension=500;
opts.dX=size(LFW_10Samples_insightface,2);
opts.model =biohashingKey(hamming_dimension,size(LFW_10Samples_insightface,2));
labels=ceil(0.1:0.1:158);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[transformed_data] = biohashing(LFW_10Samples_insightface,opts.model);
t1=clock;

%% reconstruct the first one
for i=1:3
    disp(['reconstructing ',num2str(i)])
    to_retrieve_hash=transformed_data((i-1)*10+1,:); % first of the template are used to reconstruct
    %rng default % For reproducibility
    f_fitness = @(x)fitness_biohashing(x,to_retrieve_hash,opts); % fitness function
    f_constr = []; % constrain function
    if (i==1)
        reconstruct_plot(f_fitness,f_constr,opts);
        saveas(gcf,['graph\biohashing_ga.svg']);
    else
        reconstruct(f_fitness,f_constr,opts);
    end
end

t2=clock;

timespend1=etime(t2,t1)/3;



randnum=orth(rand(size(LFW_10Samples_insightface,2)));

for a=1:size(LFW_10Samples_insightface,1)
    new_LFW_10Samples_insightface(a,:)=LFW_10Samples_insightface(a,:)* randnum;
end


SHparamNew.nbits = hamming_dimension; % number of bits to code each sample 5 bits 10240
SHparamNew.doPCA=0;
SHparamNew1=trainMDSH(new_LFW_10Samples_insightface(randperm(1580,1200),:), SHparamNew);
SHparamNew1.softmod=1;
SHparamNew1.alpha=0.5; %0.1 -1.0
SHparamNew1.dX=size(LFW_10Samples_insightface,2); %0.1 -1.0


[B1,U1] = compressMDSH(new_LFW_10Samples_insightface, SHparamNew1);
transformed_data=double(U1>0);

labels=ceil(0.1:0.1:158);
t11=clock;

%% reconstruct the first one
for i=1:3
    disp(['reconstructing mdsh',num2str(i)])
    to_retrieve_hash=transformed_data((i-1)*10+1,:); % first of the template are used to reconstruct
    %rng default % For reproducibility
    f_fitness = @(x)fitness_nmdsh(x,to_retrieve_hash,SHparamNew1); % fitness function
    f_constr = []; % constrain function
    if (i==1)
        reconstruct_plot(f_fitness,f_constr,SHparamNew1);
        saveas(gcf,['graph\mdsh_ga.svg']);
    else
        reconstruct(f_fitness,f_constr,SHparamNew1);
    end
end

t22=clock;

timespend22=etime(t22,t11)/3;


Nb=200;%400
opts.lambda = 0.5;% 0.5 1 2
opts.beta = 1;% 0.5 0.8 1
opts.K = 16;
opts.L = ceil(Nb / ceil(log2(opts.K))); % train maximum number of bits
opts.gaussian=1; %1/0=gaussian/laplace
opts.dX=size(LFW_10Samples_insightface,2);
opts.model = random_IoM(opts);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% facenet iom generate dataset
db_data.X=LFW_10Samples_insightface';
[all_code, ~] = IoM(db_data, opts, opts.model);
transformed_data=all_code.Hx';


t1=clock;
%% reconstruct the first one
for i=1:3
    disp(['reconstructing ',num2str(i)])
    to_retrieve_hash=transformed_data((i-1)*10+1,:); % first of the template are used to reconstruct
    %rng default % For reproducibility
    f_fitness = @(x)fitness_iom(x,to_retrieve_hash,opts); % fitness function
    %         f_constr = @(x)constraintsofx_iom(x,to_retrieve_hash,opts); % constrain function
    if (i==1)
        reconstruct_plot(f_fitness,f_constr,opts);
        saveas(gcf,['graph\iom_ga.svg']);
    else
        reconstruct(f_fitness,[],opts);
    end
end
t2=clock;
timespend2=etime(t2,t1)/3;

