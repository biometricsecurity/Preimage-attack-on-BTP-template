% let see if we take 100
clear all;
close all;

addpath('matlab_tools');
addpath_recurse('btp')


load('data/lfw/actual_issame')
load('data/lfw/embedding_pairs_lfw_512_insightface.mat')

load('data/lfw/LFW_10Samples_insightface.mat')
load('data/lfw/LFW_label_10Samples_insightface.mat')


for alpha=[0.1 0.3 0.5 0.7 0.9]
    
    for dimensions=[10 50 128 256  ]
        
        hamming_dimension=dimensions;
        SHparamNew1.alpha=alpha; %0.1 -1.0
        SHparamNew1.nbits = hamming_dimension; % number of bits to code each sample 5 bits 10240

        load(['data/nmdsh/',num2str(SHparamNew1.alpha),'/nmdsh_reconstruct_',num2str(SHparamNew1.nbits),'.mat'],'reconstruct_x');
        load(['data/nmdsh/',num2str(SHparamNew1.alpha),'/nmdsh_eer_',num2str(SHparamNew1.nbits),'.mat'],'EER_HASH');
        load(['data/nmdsh/',num2str(SHparamNew1.alpha),'/SHparam_',num2str(SHparamNew1.nbits),'.mat'],'SHparamNew1');
        load(['data/nmdsh/',num2str(SHparamNew1.alpha),'/randnum_',num2str(SHparamNew1.nbits),'.mat'],'randnum');
        
        %     load(['data/biohashing_eer_',num2str(hamming_dimension),'.mat'],'EER_HASH');
        %     load(['data/biohashing_reconstructconstr_',num2str(hamming_dimension),'.mat'],'reconstruct_x');
        % this is another application systen and new key for the system
        
        
       randnum2=orth(rand(size(LFW_10Samples_insightface,2)));
        
        for a=1:size(LFW_10Samples_insightface,1)
            new_LFW_10Samples_insightface(a,:)=LFW_10Samples_insightface(a,:)* randnum2;
        end
        
        
        SHparamNew.nbits = hamming_dimension; % number of bits to code each sample 5 bits 10240
        SHparamNew.doPCA=0;
        SHparamNew1=trainMDSH(new_LFW_10Samples_insightface(randperm(1580,1200),:), SHparamNew);
        SHparamNew1.softmod=1;
        SHparamNew1.alpha=alpha; %0.1 -1.0
        SHparamNew1.dX=size(LFW_10Samples_insightface,2); %0.1 -1.0
        
        
        
        [B1,U1] = compressMDSH(new_LFW_10Samples_insightface, SHparamNew1);
        transformed_data=double(U1>0);
        
        
        
        labels=ceil(0.1:0.1:158);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% normal
        
        scores = 1- pdist2(transformed_data,transformed_data,'Hamming');
        hamming_gen_score = scores(labels'==labels);
        hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
        hamming_imp_score = scores(labels'~=labels);
        [EER_HASH_orig, mTSR, mFAR, mFRR, mGAR,threshold] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isnightface 3.43 % 4.40 %
        [FAR_orig,FRR_orig] = FARatThreshold(hamming_gen_score,hamming_imp_score,threshold);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% attack
        attack_label=1:158;
        
        
        
        for a=1:158
            new_reconstruct_insightface(a,:)=reconstruct_x(a,:)/randnum*randnum2;
        end
        
        
        
        [B1,U1] = compressMDSH(new_reconstruct_insightface, SHparamNew1);
        attacker_transformed_data=double(U1>0);
        
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
        str_log=[num2str(alpha),' ',num2str(dimensions),' ',num2str(threshold),' ',num2str(EER_HASH_orig),' ',num2str(FAR_orig*100),' ',num2str(FAR_attack*100),' ',num2str(overlap2*100),'\r\n'];
        disp(str_log);
        
        
        fid=fopen('logs/mdsh.log','a');
        fprintf(fid,str_log);
        fclose(fid);
    end
    
end
