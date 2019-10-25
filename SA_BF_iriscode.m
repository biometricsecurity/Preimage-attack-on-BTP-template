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
bitss=8

opts.N_BITS_BF=bitss; %3 -10 word size
opts.N_WORDS_BF=power(2,6); % block length , how many words in one block 5-9
opts.H=20;
opts.W=512;
opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));

myreconstruct_x=zeros(178,10240);
load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint1_20_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(1:20,:)=reconstruct_x(1:20,:);

load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint21_40_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(21:40,:)=reconstruct_x(21:40,:);

load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint41_60_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(41:60,:)=reconstruct_x(41:60,:);

load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint61_80_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(61:80,:)=reconstruct_x(61:80,:);

load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint81_100_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(81:100,:)=reconstruct_x(81:100,:);

load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint101_120_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(101:120,:)=reconstruct_x(101:120,:);

load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint121_140_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(121:140,:)=reconstruct_x(121:140,:);

load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint141_160_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(141:160,:)=reconstruct_x(141:160,:);

load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint161_178_',num2str(opts.N_BITS_BF),'.mat'])
myreconstruct_x(161:178,:)=reconstruct_x(161:178,:);

reconstruct_x=myreconstruct_x;

templates(1,:)
reconstruct_x(1,:)

pdist2(templates(1,:),reconstruct_x(1,:),'Jaccard')


subplot(2,1,1);
imshow(reshape(templates(2,:),[20 512]));
title('Subplot 1')

subplot(2,1,2);
imshow(reshape(reconstruct_x(1,:),[20 512]));
title('Subplot 2')