clear all;
close all;

load('data\bloomfilter\\iriscode\labels.mat')
load('data\bloomfilter\\iriscode\templates.mat')
addpath('matlab_tools');
addpath_recurse("btp")

uniqulabels=unique(labels);
indexs=[];
for i=1:length(uniqulabels)
    [value, inde]=find(labels==uniqulabels(i));
    indexs=[indexs inde(1)];
end

M = containers.Map({1},{[]});
for i=1:length(labels)
    if isKey(M,labels(i))
        M(labels(i)) =[ M(labels(i)) i];
    else
        M(labels(i)) = [i];
    end
end
remove(M,1);

%% three group
allids=M.keys;
attack_ids=[];
attack_label_x=[];
for nameidx=1:length(allids)
    thisuseremplate=M(allids{nameidx});
    cnt=length(thisuseremplate);
    if cnt>3
        attack_label_x = [attack_label_x thisuseremplate(1)];
        attack_ids=[attack_ids thisuseremplate(1:3)];
    end
end


%% reconstruct the first one
% I want the first of each user
% 3:10
for bitss=8:10
    
    opts.N_BITS_BF=bitss; %3 -10 word size
    opts.N_WORDS_BF=power(2,6); % block length , how many words in one block 5-9
    opts.H=20;
    opts.W=512;
    opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
    opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
    opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
    opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));
    
    myreconstruct_x=zeros(178,10240);
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle1_20_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(1:20,:)=reconstruct_x(1:20,:);
    
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle21_40_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(21:40,:)=reconstruct_x(21:40,:);
    
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle41_60_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(41:60,:)=reconstruct_x(41:60,:);
    
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle61_80_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(61:80,:)=reconstruct_x(61:80,:);
    
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle81_100_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(81:100,:)=reconstruct_x(81:100,:);
    
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle101_120_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(101:120,:)=reconstruct_x(101:120,:);
    
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle121_140_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(121:140,:)=reconstruct_x(121:140,:);
    
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle141_160_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(141:160,:)=reconstruct_x(141:160,:);
    
    load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle161_178_',num2str(opts.N_BITS_BF),'.mat'])
    myreconstruct_x(161:178,:)=reconstruct_x(161:178,:);
    
    reconstruct_x=myreconstruct_x;
    
    
    clear bf_templates;
    for i=1:length(labels)
        
        [bf_templates(i,:)] = extract_BFs_from_Iriscode_features(templates(i,:),opts);
    end
    
  
%     
    % chaneg a matching protocol
    scores=zeros(length(labels));
    for jj=1: length(labels)
        jj
        for kk=1: length(labels)
            scores(jj,kk)=1-bloomfilter_hamming(bf_templates(jj,:),bf_templates(kk,:),opts);
            %             scores(jj,kk)=1-pdist2(bf_templates(jj,:),bf_templates(kk,:),'Hamming');
        end
    end
    
    hamming_gen_score = scores(labels'==labels);
    hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
    hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=0));
    hamming_imp_score = scores(labels'~=labels);
    hamming_imp_score = hamming_imp_score(find(hamming_imp_score~=0));
    
    
    [EER_HASH_orig, mTSR, mFAR, mFRR, mGAR,threshold] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isnightface 3.43 % 4.40 %
    [FAR_orig,FRR_orig] = FARatThreshold(hamming_gen_score,hamming_imp_score,threshold);
    
    %%%%%%%%%%%*****************************lets reconstart it
    uniqulabels=unique(labels);
    clear reconstruct_bf_templates;
    for i=1:size(reconstruct_x,1)
        [reconstruct_bf_templates(i,:)] = extract_BFs_from_Iriscode_features(reconstruct_x(i,:),opts);
    end
    
    
    approxmate_scores=zeros(length(labels),size(reconstruct_x,1));
    for jj=1: length(labels)
        jj
        for kk=1: size(reconstruct_x,1)
            approxmate_scores(jj,kk)=1-bloomfilter_hamming(bf_templates(jj,:),reconstruct_bf_templates(kk,:),opts);
        end
    end
    attack_label=labels(attack_label_x);
    approxmate_gen_score = approxmate_scores(labels'==attack_label);
    approxmate_gen_score = approxmate_gen_score(find(approxmate_gen_score~=1));
    approxmate_imp_score = approxmate_scores(labels'~=attack_label);
    approxmate_imp_score = approxmate_imp_score(find(approxmate_imp_score~=0));
    
    %     [EER_HASH_attack, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, approxmate_gen_score, 0.001);  % isnightface 3.43 % 4.40 %
    [FAR_attack,FRR_attack] = FARatThreshold(hamming_gen_score,approxmate_gen_score,threshold);
    
    %     plothisf_revocable(hamming_gen_score(randperm(length(hamming_gen_score),2000)),hamming_imp_score(randperm(length(hamming_imp_score),2000)),approxmate_gen_score,'bit',1,1,500);
    %     saveas(gcf,['data/bloomfilter/distributionattack',num2str(opts.N_BITS_BF),'.tif']);
    %
    [mu_imp,sigma_imp] = mynormfit(hamming_imp_score);
    
    [mu_mate_imp,sigma_mate_imp] = mynormfit(approxmate_gen_score);
    
    [overlap2] = calc_overlap_twonormal(sigma_imp,sigma_mate_imp,mu_imp,mu_mate_imp,0,1,0.01);
    
    
    str_log=[num2str(opts.N_BITS_BF),' ',num2str(threshold),' ',num2str(EER_HASH_orig),' ',num2str(FAR_orig*100),' ',num2str(FAR_attack*100),' ',num2str(overlap2*100),'\r\n'];
    disp(str_log);
    
    
    fid=fopen(['logs/bf_noconstraintsingle',num2str(bitss),'.log'],'a');
    fprintf(fid,str_log);
    fclose(fid);
    
    
end

