%testing Iris code performance 
clear all;
close all;
% load('data\bloomfilter\bf_templates.mat')
load('data\bloomfilter\iriscode\labels.mat')
load('data\bloomfilter\iriscode\templates.mat')
% load('data\bloomfilter\iriscode\Codes_lg_labels.mat')
% % load('data\bloomfilter\iriscode\Codes_qsw_templates.mat')
% load('data\bloomfilter\iriscode\Codes_lg_templates.mat')

addpath('matlab_tools');
addpath_recurse("btp")

templates = double(templates);
uniqulabels=unique(labels);
indexs=[];
for i=1:length(uniqulabels)
    [value, inde]=find(labels==uniqulabels(i));
    indexs=[indexs inde(1)];
end

%% reconstruct the first one

opts.N_BITS_BF=1; %3 -10 word size
opts.N_WORDS_BF=power(2,5); % block length , how many words in one block 5-9
opts.H=20;
opts.W=512;
opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));
opts

%
% %  chaneg a matching protocol
scores_unprot=zeros(length(labels));
for jj=1: 50%length(labels)
    jj
    for kk=jj: length(labels)
        %         scores_unprot(jj,kk)=1-pdist2(templates(jj,:),templates(kk,:),'Hamming');
        scores_unprot(jj,kk)=1-bloomfilter_hamming(templates(jj,:),templates(kk,:),opts);
        
    end
end


hamming_gen_score = scores_unprot(labels'==labels);
hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=0));
hamming_imp_score = scores_unprot(labels'~=labels);
hamming_imp_score = hamming_imp_score(find(hamming_imp_score~=0));


[EER_HASH_unprot, mTSR, mFAR, mFRR, mGAR] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isn
