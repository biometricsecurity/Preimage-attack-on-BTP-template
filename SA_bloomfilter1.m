clear all;
close all;
% load('data\bloomfilter\bf_templates.mat')
load('data\bloomfilter\iriscode\labels.mat')
load('data\bloomfilter\iriscode\templates.mat')
addpath('matlab_tools');
addpath_recurse("btp")

uniqulabels=unique(labels);
indexs=[];
for i=1:length(uniqulabels)
    [value, inde]=find(labels==uniqulabels(i));
    indexs=[indexs inde(1)];
end

%% reconstruct the first one
% I want the first of each user
% 3:10
for bitss=8
    opts.N_BITS_BF=bitss; %3 -10 word size
    opts.N_WORDS_BF=power(2,5); % block length , how many words in one block 5-9
    opts.H=20;
    opts.W=512;
    opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
    opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
    opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
    opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));
    
    clear bf_templates;
    for i=1:length(labels)
        
        [bf_templates(i,:)] = extract_BFs_from_Iriscode_features(templates(i,:),opts);
    end
    
    save(['data/bloomfilter/bf_templates',num2str(opts.N_BITS_BF),'.mat'],'bf_templates')
   
    
    for j=1:10
        %rng default % For reproducibility
        f_fitness = @(x)fitness_bloomfilter(x,bf_templates(indexs(j),:),opts); % fitness function
        f_constr = []; % constrain function
        
        reconstruct_x(j,:) = reconstruct_bloom(f_fitness,f_constr,opts);
    end
    
    save(['data/bloomfilter/bloomfilter_reconstructnoconstraint_',num2str(opts.N_BITS_BF),'.mat'],'reconstruct_x');
    clear reconstruct_bf_templates;
    for i=1:length(uniqulabels)
        i
        [reconstruct_bf_templates(i,:)] = extract_BFs_from_Iriscode_features(reconstruct_x(i,:),opts);
    end
    
    approxmate_scores=zeros(length(labels),length(uniqulabels));
    for jj=1: length(labels)
        jj
        for kk=jj: length(uniqulabels)
            approxmate_scores(jj,kk)=1-bloomfilter_hamming(bf_templates(jj,:),reconstruct_bf_templates(kk,:),opts);
        end
    end
    save(['data/bloomfilter/bloomfilter_approxmate_scores_',num2str(opts.N_BITS_BF),'.mat'],'approxmate_scores');
    
    
    approxmate_gen_score = approxmate_scores(labels'==uniqulabels);
    approxmate_gen_score = approxmate_gen_score(find(approxmate_gen_score~=1));
    approxmate_imp_score = approxmate_scores(labels'~=uniqulabels);
    [EER_HASH_attack, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, approxmate_gen_score, 0.001);  % isnightface 3.43 % 4.40 %
    
    plothisf_revocable(hamming_gen_score(randperm(length(hamming_gen_score),2000)),hamming_imp_score(randperm(length(hamming_imp_score),2000)),approxmate_gen_score,'bit',1,1,500);
    saveas(gcf,['data/bloomfilter/distributionattack',num2str(opts.N_BITS_BF),'.tif']);
    
    [mu_imp,sigma_imp] = mynormfit(hamming_imp_score);
    
    [mu_mate_imp,sigma_mate_imp] = mynormfit(approxmate_gen_score);
    
    [overlap2] = calc_overlap_twonormal(sigma_imp,sigma_mate_imp,mu_imp,mu_mate_imp,0,1,0.01);
    
    disp([num2str(EER_HASH),' ',num2str(EER_HASH_attack),' ',num2str(overlap2)])
    overlap2= [EER_HASH EER_HASH_attack overlap2 ];
    save(['data/bloomfilter/bloomfilter_overlap_',num2str(opts.N_BITS_BF),'.mat'],'overlap2');
    
    
end

