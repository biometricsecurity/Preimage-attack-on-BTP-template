function SA_bloomfilter_frommultitemplate_single(bitss,starti,endi)


% load('E:\my research source code\20190316-SA Attack\data\bloomfilter\bf_templates.mat')
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
for nameidx=1:length(allids)
    thisuseremplate=M(allids{nameidx});
    cnt=length(thisuseremplate);
    if cnt>3
        attack_ids=[attack_ids thisuseremplate(1:3)];
    end
end


opts.N_BITS_BF=bitss; %3 -10 word size
opts.N_WORDS_BF=power(2,6); % block length , how many words in one block 5-9
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


for j=starti:endi
    %rng default % For reproducibility
    f_fitness = @(x)fitness_bloomfilter(x,bf_templates(attack_ids((j-1)*3+1),:),opts); % fitness function
    f_constr = []; % constrain function
    
    reconstruct_x(j,:) = reconstruct_bloom(f_fitness,f_constr,opts);

end

save(['data/bloomfilter/bloomfilter_reconstructnoconstraintsingle',num2str(starti),'_',num2str(endi),'_',num2str(opts.N_BITS_BF),'.mat'],'reconstruct_x');



end