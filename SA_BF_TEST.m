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

opts.N_BITS_BF=9; %3 -10 word size
opts.N_WORDS_BF=power(2,5); % block length , how many words in one block 5-9
opts.H=20;
opts.W=512;
opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));
opts


%  chaneg a matching protocol
scores_unprot=zeros(length(labels));
for jj=1: 100%length(labels)
    jj
    for kk=jj: length(labels)
        scores_unprot(jj,kk)=1-pdist2(templates(jj,:),templates(kk,:),'Hamming');
    end
end


hamming_gen_score = scores_unprot(labels'==labels);
hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=0));
hamming_imp_score = scores_unprot(labels'~=labels);
hamming_imp_score = hamming_imp_score(find(hamming_imp_score~=0));


[EER_HASH_unprot, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isn

clear bf_templates;
for i=1:length(labels)
    [bf_templates(i,:)] = extract_BFs_from_Iriscode_features(templates(i,:),opts);
end

% chaneg a matching protocol
scores=zeros(length(labels));
for jj=1: 100%length(labels)
    jj
    for kk=jj: length(labels)
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


f_fitness = @(x)fitness_bloomfilter(x,bf_templates(1,:),opts); % fitness function
f_constr = []; % constrain function

reconstruct_x(1,:) = reconstruct_bloom(f_fitness,f_constr,opts);
[reconstruct_bf_templates(1,:)] = extract_BFs_from_Iriscode_features(reconstruct_x(1,:),opts);


my_score=[];
my_IMP=[];
for a=1:10
    
    tmp=1-bloomfilter_hamming(bf_templates(a,:),reconstruct_bf_templates(1,:),opts);
    tmp2=1-bloomfilter_hamming(bf_templates(a,:),bf_templates(11+a,:),opts);
    my_score=[my_score tmp];
    my_IMP=[my_IMP tmp2 ];
end
mean(hamming_imp_score)
mean(scores(1,11:1332))
mean(my_score)
mean(my_IMP)
[FAR_attack,FRR_attack] = FARatThreshold(hamming_gen_score,my_score,threshold)

% for j=1:length(indexs)
%    % rng default % For reproducibility
%     f_fitness = @(x)fitness_bloomfilter(x,bf_templates(indexs(j),:),opts); % fitness function
%     f_constr = []; % constrain function
%
%     reconstruct_x(j,:) = reconstruct_bloom(f_fitness,f_constr);
% end


