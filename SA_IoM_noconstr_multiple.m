clear all;
close all;
load('data/lfw/LFW_10Samples_insightface.mat')
load('data/lfw/LFW_label_10Samples_insightface.mat')

addpath('matlab_tools');
addpath_recurse('btp')
labels=ceil(0.1:0.1:158);

for dimensions=[500 ] %16 32 64 100 200 300 400 500
    
    Nb=dimensions;%400
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
    
    
    scores = 1- pdist2(transformed_data,transformed_data,'Hamming');
    hamming_gen_score = scores(labels'==labels);
    hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
    hamming_imp_score = scores(labels'~=labels);
    
    
    [EER_HASH, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isnightface 3.43 % 4.40 %
    reconstruct_x=zeros(158,512);
    
    %% reconstruct the first one
    for jjj=1:5
        %% reconstruct the first one
        for i=1:158
            disp(['reconstructing ',num2str(i)])
            to_retrieve_hash=transformed_data((i-1)*10+1:1:(i-1)*10+jjj,:); % first of the template are used to reconstruct

            %rng default % For reproducibility
            f_fitness = @(x)fitness_iom(x,to_retrieve_hash,opts); % fitness function
            %         f_constr = @(x)constraintsofx_iom(x,to_retrieve_hash,opts); % constrain function
            
            reconstruct_x(i,:) = reconstruct(f_fitness,[],opts);
        end
        save(['data/20190620iomhashing_reconstructnoconstraint_',num2str(dimensions),'_',num2str(jjj),'.mat'],'reconstruct_x');
        save(['data/20190620iomhashing_eer_',num2str(dimensions),'_',num2str(jjj),'.mat'],'EER_HASH');
        
    end

end


