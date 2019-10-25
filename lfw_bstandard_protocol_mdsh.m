clear all
addpath('matlab_tools');
addpath_recurse('btp')
%

%
load('data/lfw/actual_issame')
load('data/lfw/embedding_pairs_lfw_512_insightface.mat')



randnum=orth(rand(size(embedding_pairs_lfw_512_insightface,2)));

for a=1:size(embedding_pairs_lfw_512_insightface,1)
    new_embedding_pairs_lfw_512_insightface(a,:)=embedding_pairs_lfw_512_insightface(a,:)* randnum;
end


SHparamNew.nbits = 1024; % number of bits to code each sample 5 bits 10240
SHparamNew.doPCA=0;
SHparamNew1 = trainMDSH(new_embedding_pairs_lfw_512_insightface(randperm(12000,4000),:), SHparamNew);
SHparamNew1.softmod=1;
SHparamNew1.alpha=0.2; %0.1 -1.0



[B1,U1] = compressMDSH(new_embedding_pairs_lfw_512_insightface, SHparamNew1);
hashed_code_gallery=double(U1>0);


gen = [];
imp = [];
for i=1:6000
    sampleA=hashed_code_gallery((i-1)*2+1,:);
    sampleB=hashed_code_gallery((i-1)*2+2,:);
    similarity=  1-pdist2(sampleA,sampleB,'jaccard');
    if(actual_issame(i))
        gen = [gen; similarity];
    else
        imp = [imp; similarity];
    end
end



scores = [gen' imp'];
[EER, mTSR, mFAR, mFRR, mGAR] = computeperformance(1-imp, 1-gen, 0.0001); % 0.63%  7.48 %

