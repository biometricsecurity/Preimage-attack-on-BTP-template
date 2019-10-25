clear all;
close all;
load('data\lfw\LFW_10Samples_insightface.mat')
load('data\lfw\LFW_label_10Samples_insightface.mat')

addpath('matlab_tools');
addpath_recurse("btp")

for dimensions=[16 32 64 100 200 300 400 500 ]
    
    hamming_dimension=dimensions;
    opts.dX=size(LFW_10Samples_insightface,2);
    opts.model =biohashingKey(hamming_dimension,size(LFW_10Samples_insightface,2));
    labels=ceil(0.1:0.1:158);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [transformed_data] = biohashing(LFW_10Samples_insightface,opts.model);
    
    
    scores = 1- pdist2(transformed_data,transformed_data,'Hamming');
    hamming_gen_score = scores(labels'==labels);
    hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
    hamming_imp_score = scores(labels'~=labels);
    
    
    [EER_HASH, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isnightface 3.43 % 4.40 %
    reconstruct_x=zeros(158,512);
    %% reconstruct the first one
    for i=1:158
        disp(['reconstructing ',num2str(i)])
        to_retrieve_hash=transformed_data((i-1)*10+1,:); % first of the template are used to reconstruct
        %rng default % For reproducibility
        f_fitness = @(x)fitness_biohashing(x,to_retrieve_hash,opts); % fitness function
        f_constr = @(x)constraintsofx_biohashing(x,to_retrieve_hash,opts); % constrain function
        reconstruct_x(i,:) = reconstruct(f_fitness,f_constr,opts);
    end
    
    save(['data/biohashing_reconstructconstr_',num2str(hamming_dimension),'.mat'],'reconstruct_x');
    save(['data/biohashing_eer_',num2str(hamming_dimension),'.mat'],'EER_HASH');
    
    
end




