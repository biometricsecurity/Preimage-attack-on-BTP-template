% let see if we take 100
clear all;
close all;

addpath('matlab_tools');
addpath_recurse("btp")

load('data\lfw\LFW_10Samples_insightface.mat')
load('data\lfw\LFW_label_10Samples_insightface.mat')

for dimensions=[400]
    
    hamming_dimension=dimensions;
    load(['data/biohashing_reconstruct_',num2str(hamming_dimension),'.mat'],'reconstruct_x');
    load(['data/biohashing_eer_',num2str(hamming_dimension),'.mat'],'EER_HASH');
    
    % this is another application systen and new key for the system
    
    opts.dX=size(LFW_10Samples_insightface,2);
    opts.model =biohashingKey(hamming_dimension,size(LFW_10Samples_insightface,2));
    labels=ceil(0.1:0.1:158);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% normal
    
    [transformed_data] = biohashing(LFW_10Samples_insightface,opts.model);
    scores = 1- pdist2(transformed_data,transformed_data,'Hamming');
    hamming_gen_score = scores(labels'==labels);
    hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
    hamming_imp_score = scores(labels'~=labels);
    [EER_HASH_orig, mTSR, mFAR, mFRR, mGAR,threshold] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isnightface 3.43 % 4.40 %
    [FAR_orig,FRR_orig] = FARatThreshold(hamming_gen_score,hamming_imp_score,threshold);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% attack
    attack_label=1:158;
    [attacker_transformed_data] = biohashing(reconstruct_x,opts.model);
    
    approxmate_scores = 1- pdist2(attacker_transformed_data,transformed_data,'Hamming');
    approxmate_gen_score = approxmate_scores(attack_label'==labels);
    approxmate_gen_score = approxmate_gen_score(find(approxmate_gen_score~=1));
    approxmate_imp_score = approxmate_scores(attack_label'~=labels);
    [EER_HASH_attack, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, approxmate_gen_score, 0.001);  % isnightface 3.43 % 4.40 %
    
    [FAR_attack,FRR_attack] = FARatThreshold(hamming_gen_score,approxmate_gen_score,threshold);
    
    
    plothisf_revocable(hamming_gen_score(randperm(length(hamming_gen_score),2000)),hamming_imp_score(randperm(length(hamming_imp_score),2000)),approxmate_gen_score,'bit',1,1,200);
    
    [mu_imp,sigma_imp] = mynormfit(hamming_imp_score);
    
    [mu_mate_imp,sigma_mate_imp] = mynormfit(approxmate_gen_score);
    
    [overlap2] = calc_overlap_twonormal(sigma_imp,sigma_mate_imp,mu_imp,mu_mate_imp,0,1,0.01);
    str_log=[num2str(dimensions),' ',num2str(threshold),' ',num2str(EER_HASH_orig),' ',num2str(FAR_orig*100),' ',num2str(FAR_attack*100),' ',num2str(overlap2*100),'\r\n'];
    disp(str_log);
    
    
    fid=fopen('logs/biohashing.log','a');
    fprintf(fid,str_log);
    fclose(fid);
end
