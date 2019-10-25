% % let see if we take 100
% clear all;
% close all;
%
% addpath('matlab_tools');
% addpath_recurse("btp")
%
% load('data\lfw\LFW_10Samples_insightface.mat')
% load('data\lfw\LFW_label_10Samples_insightface.mat')
%
% labels=ceil(0.1:0.1:158);
% sids=nchoosek(1:158,2);
% impsc=[];
% for aaa=1:size(sids,1)
%     A=LFW_10Samples_insightface((sids(aaa,1)-1)*10+1,:);
%     B=LFW_10Samples_insightface((sids(aaa,2)-1)*10+1,:);
%     distance= norm(A-B)/(norm(A)+norm(B));
%     impsc=[impsc distance];
% end
%
% avg_imp=mean(impsc);
%
% gensc=[];
% sids=nchoosek(1:10,2);
% for bbb=1:158
%     for aaa=1:size(sids,1)
%         A=LFW_10Samples_insightface((bbb-1)*10+sids(aaa,1),:);
%         B=LFW_10Samples_insightface((bbb-1)*10+sids(aaa,2),:);
%         distance= norm(A-B)/(norm(A)+norm(B));
%         gensc=[gensc distance];
%     end
% end
% avg_gen=mean(gensc);
%
% cnttt=1;
% for dimensions=[16 32 64 100 200 300 400 500 ]
%
%     hamming_dimension=dimensions;
%     load(['data/biohashing_reconstruct_',num2str(hamming_dimension),'.mat'],'reconstruct_x');
%
%     % this is another application systen and new key for the system
%     x_score=[];
%     for kkk=1: size(reconstruct_x,1)
%         thisuser=LFW_10Samples_insightface((kkk-1)*10+1,:);
%         distance= norm(thisuser-reconstruct_x(kkk,:))/(norm(thisuser)+norm(reconstruct_x(kkk,:)));
%         x_score = [x_score distance];
%     end
%     x_scores(cnttt)= mean(x_score);
%     cnttt=cnttt+1;
% end
% 
% clear all;
% close all;
% 
% load('data\bloomfilter\\iriscode\labels.mat')
% load('data\bloomfilter\\iriscode\templates.mat')
% addpath('matlab_tools');
% addpath_recurse("btp")
% 
% uniqulabels=unique(labels);
% indexs=[];
% for i=1:length(uniqulabels)
%     [value, inde]=find(labels==uniqulabels(i));
%     indexs=[indexs inde(1)];
% end
% 
% M = containers.Map({1},{[]});
% for i=1:length(labels)
%     if isKey(M,labels(i))
%         M(labels(i)) =[ M(labels(i)) i];
%     else
%         M(labels(i)) = [i];
%     end
% end
% remove(M,1);
% 
% %% three group
% allids=M.keys;
% attack_ids=[];
% attack_label_x=[];
% for nameidx=1:length(allids)
%     thisuseremplate=M(allids{nameidx});
%     cnt=length(thisuseremplate);
%     if cnt>3
%         attack_label_x = [attack_label_x thisuseremplate(1)];
%         attack_ids=[attack_ids thisuseremplate(1:3)];
%     end
% end
% 
% 
% 
% %% reconstruct the first one
% % I want the first of each user
% % 3:10
% cnttt=1;
% for bitss=8:10
%     
%     opts.N_BITS_BF=bitss; %3 -10 word size
%     opts.N_WORDS_BF=power(2,6); % block length , how many words in one block 5-9
%     opts.H=20;
%     opts.W=512;
%     opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
%     opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
%     opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
%     opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));
%     
%     myreconstruct_x=zeros(178,10240);
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint1_20_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(1:20,:)=reconstruct_x(1:20,:);
%     
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint21_40_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(21:40,:)=reconstruct_x(21:40,:);
%     
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint41_60_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(41:60,:)=reconstruct_x(41:60,:);
%     
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint61_80_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(61:80,:)=reconstruct_x(61:80,:);
%     
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint81_100_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(81:100,:)=reconstruct_x(81:100,:);
%     
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint101_120_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(101:120,:)=reconstruct_x(101:120,:);
%     
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint121_140_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(121:140,:)=reconstruct_x(121:140,:);
%     
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint141_160_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(141:160,:)=reconstruct_x(141:160,:);
%     
%     load(['data\bloomfilter\',num2str(bitss),'\bloomfilter_reconstructnoconstraint161_178_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(161:178,:)=reconstruct_x(161:178,:);
%     
%     reconstruct_x=myreconstruct_x;
%     
%     x_score=[];
%     for kkk=1: size(reconstruct_x,1)
%         A=templates(attack_label_x(kkk)+1,:);
%         B=reconstruct_x(kkk,:);
%         distance= pdist2(A,B,'Hamming');
%         x_score = [x_score distance];
%     end
%     x_scores(cnttt)= mean(x_score);
%     cnttt=cnttt+1;
%     
% end
% 
% 

% clear all;
% close all;
% 
% load('data\bloomfilter\\iriscode\labels.mat')
% load('data\bloomfilter\\iriscode\templates.mat')
% addpath('matlab_tools');
% addpath_recurse("btp")
% 
% uniqulabels=unique(labels);
% indexs=[];
% for i=1:length(uniqulabels)
%     [value, inde]=find(labels==uniqulabels(i));
%     indexs=[indexs inde(1)];
% end
% 
% M = containers.Map({1},{[]});
% for i=1:length(labels)
%     if isKey(M,labels(i))
%         M(labels(i)) =[ M(labels(i)) i];
%     else
%         M(labels(i)) = [i];
%     end
% end
% remove(M,1);
% 
% %% three group
% allids=M.keys;
% attack_ids=[];
% attack_label_x=[];
% for nameidx=1:length(allids)
%     thisuseremplate=M(allids{nameidx});
%     cnt=length(thisuseremplate);
%     if cnt>3
%         attack_label_x = [attack_label_x thisuseremplate(1)];
%         attack_ids=[attack_ids thisuseremplate(1:3)];
%     end
% end
% 
% 
% 
% %% reconstruct the first one
% % I want the first of each user
% % 3:10
% cnttt=1;
% for bitss=8:10
%     
%     opts.N_BITS_BF=bitss; %3 -10 word size
%     opts.N_WORDS_BF=power(2,6); % block length , how many words in one block 5-9
%     opts.H=20;
%     opts.W=512;
%     opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
%     opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
%     opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
%     opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));
%     
%     myreconstruct_x=zeros(178,10240);
%       load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle1_20_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(1:20,:)=reconstruct_x(1:20,:);
%     
%     load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle21_40_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(21:40,:)=reconstruct_x(21:40,:);
%     
%     load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle41_60_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(41:60,:)=reconstruct_x(41:60,:);
%     
%     load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle61_80_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(61:80,:)=reconstruct_x(61:80,:);
%     
%     load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle81_100_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(81:100,:)=reconstruct_x(81:100,:);
%     
%     load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle101_120_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(101:120,:)=reconstruct_x(101:120,:);
%     
%     load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle121_140_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(121:140,:)=reconstruct_x(121:140,:);
%     
%     load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle141_160_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(141:160,:)=reconstruct_x(141:160,:);
%     
%     load(['data\bloomfilter\single\',num2str(bitss),'\bloomfilter_reconstructnoconstraintsingle161_178_',num2str(opts.N_BITS_BF),'.mat'])
%     myreconstruct_x(161:178,:)=reconstruct_x(161:178,:);
%     
%     
%     reconstruct_x=myreconstruct_x;
%     
%     x_score=[];
%     for kkk=1: size(reconstruct_x,1)
%         A=templates(attack_label_x(kkk),:);
%         B=reconstruct_x(kkk,:);
%         distance= pdist2(A,B,'Hamming');
%         x_score = [x_score distance];
%     end
%     x_scores(cnttt)= mean(x_score);
%     cnttt=cnttt+1;
%     
% end
% 
% 
% 
