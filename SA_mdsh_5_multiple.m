clear allopts
addpath('matlab_tools');
addpath_recurse('btp')
%

%
load('data/lfw/actual_issame')
load('data/lfw/embedding_pairs_lfw_512_insightface.mat')

load('data/lfw/LFW_10Samples_insightface.mat')
load('data/lfw/LFW_label_10Samples_insightface.mat')
labels=ceil(0.1:0.1:158);

for bits=[500]
    
    randnum=orth(rand(size(LFW_10Samples_insightface,2)));
    
    for a=1:size(LFW_10Samples_insightface,1)
        new_LFW_10Samples_insightface(a,:)=LFW_10Samples_insightface(a,:)* randnum;
    end
    
    
    SHparamNew.nbits = bits; % number of bits to code each sample 5 bits 10240
    SHparamNew.doPCA=0;
    SHparamNew1=trainMDSH(new_LFW_10Samples_insightface(randperm(1580,1200),:), SHparamNew);
    SHparamNew1.softmod=1;
    SHparamNew1.alpha=0.5; %0.1 -1.0
    SHparamNew1.dX=size(LFW_10Samples_insightface,2); %0.1 -1.0
    
    
    
    [B1,U1] = compressMDSH(new_LFW_10Samples_insightface, SHparamNew1);
    hashed_code_gallery=double(U1>0);
    
    
    scores = 1- pdist2(hashed_code_gallery,hashed_code_gallery,'Hamming');
    hamming_gen_score = scores(labels'==labels);
    hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
    hamming_imp_score = scores(labels'~=labels);
    
    
    [EER_HASH, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isnightface 3.43 % 4.40 %
    
    %% reconstruct the first one
    for jjj=5
        for i=1:158
            to_retrieve_hash=hashed_code_gallery((i-1)*10+1:1:(i-1)*10+jjj,:); % first of the template are used to reconstruct
            
            %rng default % For reproducibility
            f_fitness = @(x)fitness_nmdsh(x,to_retrieve_hash,SHparamNew1); % fitness function
            f_constr = []; % constrain function
            
            reconstruct_x(i,:) = reconstruct(f_fitness,f_constr,SHparamNew1);
        end
        
        
        save(['data/nmdsh/',num2str(SHparamNew1.alpha),'/20190620nmdsh_reconstruct_',num2str(SHparamNew1.nbits),'_',num2str(jjj),'.mat'],'reconstruct_x');
        save(['data/nmdsh/',num2str(SHparamNew1.alpha),'/20190620nmdsh_eer_',num2str(SHparamNew1.nbits),'_',num2str(jjj),'.mat'],'EER_HASH');
        save(['data/nmdsh/',num2str(SHparamNew1.alpha),'/20190620SHparam_',num2str(SHparamNew1.nbits),'_',num2str(jjj),'.mat'],'SHparamNew1');
        save(['data/nmdsh/',num2str(SHparamNew1.alpha),'/20190620randnum_',num2str(SHparamNew1.nbits),'_',num2str(jjj),'.mat'],'randnum');
    end
    
    
    
end

