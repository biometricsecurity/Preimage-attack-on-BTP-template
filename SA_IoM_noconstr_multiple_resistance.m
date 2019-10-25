clear all;
close all;
load('data/lfw/LFW_10Samples_insightface.mat')
load('data/lfw/LFW_label_10Samples_insightface.mat')

addpath('matlab_tools');
addpath_recurse('btp')


for dimensions=[ 500 ]
    for jjj=1:5
        hamming_dimension=dimensions;
        
        load(['data/20190620iomhashing_reconstructnoconstraint_',num2str(dimensions),'_',num2str(jjj),'.mat'],'reconstruct_x');
        load(['data/20190620iomhashing_eer_',num2str(dimensions),'_',num2str(jjj),'.mat'],'EER_HASH');
        % this is another application systen and new key for the system
        
        labels=ceil(0.1:0.1:158);
        
        % this is another application systen and new key for the system
        
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
        [EER_HASH_orig, mTSR, mFAR, mFRR, mGAR,threshold] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isnightface 3.43 % 4.40 %
        [FAR_orig,FRR_orig] = FARatThreshold(hamming_gen_score,hamming_imp_score,threshold);
        
        attack_label=1:158;
        %% facenet iom generate dataset
        reconstruct_x = reconstruct_x./ sum(reconstruct_x,2); % what is we normlized it
        db_data.X=reconstruct_x';
        [all_code, ~] = IoM(db_data, opts, opts.model);
        attacker_transformed_data=all_code.Hx';
        
        
        
        approxmate_scores = 1- pdist2(attacker_transformed_data,transformed_data,'Hamming');
        approxmate_gen_score = approxmate_scores(attack_label'==labels);
        approxmate_gen_score = approxmate_gen_score(find(approxmate_gen_score~=1));
        approxmate_imp_score = approxmate_scores(attack_label'~=labels);
        [EER_HASH_attack, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, approxmate_gen_score, 0.001);  % isnightface 3.43 % 4.40 %
        [FAR_attack,FRR_attack] = FARatThreshold(hamming_gen_score,approxmate_gen_score,threshold);
        
        % plothisf_revocable(hamming_gen_score(randperm(length(hamming_gen_score),2000)),hamming_imp_score(randperm(length(hamming_imp_score),2000)),approxmate_gen_score,'bit',1,1,500);
        
        [mu_imp,sigma_imp] = mynormfit(hamming_imp_score);
        
        [mu_mate_imp,sigma_mate_imp] = mynormfit(approxmate_gen_score);
        
        [overlap2] = calc_overlap_twonormal(sigma_imp,sigma_mate_imp,mu_imp,mu_mate_imp,0,1,0.01);
        str_log=[num2str(dimensions),' ',num2str(jjj),' ',num2str(threshold),' ',num2str(EER_HASH_orig),' ',num2str(FAR_orig*100),' ',num2str(FAR_attack*100),' ',num2str(overlap2*100),'\r\n'];
        disp(str_log);
        
        
        fid=fopen('logs/0701iom_multi.log','a');
        fprintf(fid,str_log);
        fclose(fid);
        
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
        str_log=[num2str(dimensions),' ',num2str(jjj),' ',num2str(threshold),' ',num2str(EER_HASH_orig),' ',num2str(FAR_orig*100),' ',num2str(FAR_attack*100),' ',num2str(overlap2*100),'\r\n'];
        disp(str_log);
        
        
        fid=fopen('logs/0701iom_biohashing_multi.log','a');
        fprintf(fid,str_log);
        fclose(fid);
        
             
        hamming_dimension=dimensions;
        SHparamNew1.alpha=0.5; %0.1 -1.0
        SHparamNew1.nbits = hamming_dimension; % number of bits to code each sample 5 bits 10240
        
        randnum2=orth(rand(size(LFW_10Samples_insightface,2)));
        
        for a=1:size(LFW_10Samples_insightface,1)
            new_LFW_10Samples_insightface(a,:)=LFW_10Samples_insightface(a,:)* randnum2;
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
            new_reconstruct_insightface(a,:)=reconstruct_x(a,:)*randnum2;
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
        
        str_log=[num2str(dimensions),' ',num2str(jjj),' ',num2str(threshold),' ',num2str(EER_HASH_orig),' ',num2str(FAR_orig*100),' ',num2str(FAR_attack*100),' ',num2str(overlap2*100),'\r\n'];
        disp(str_log);
        
        
        fid=fopen('logs/0701iom_mdsh_multi.log','a');
        fprintf(fid,str_log);
        fclose(fid);
        
    end
end
