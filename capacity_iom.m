clear all;
close all;
load('data/lfw/LFW_10Samples_insightface.mat')
load('data/lfw/LFW_label_10Samples_insightface.mat')

addpath('matlab_tools');
addpath_recurse('btp')

orig_scores = pdist2(LFW_10Samples_insightface,LFW_10Samples_insightface,'euclidean');
Iset=nonzeros(triu( reshape(1:numel(orig_scores), size(orig_scores)) ));
orig_distance=orig_scores(Iset);

cnt=1;
for dimensions=[16 32 64 100:50:500 600:100:1000 ]
    
    
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
    
    
    hash_scores =pdist2(transformed_data,transformed_data,'Hamming');
    
    scores = 1- hash_scores;
    hamming_gen_score = scores(labels'==labels);
    hamming_gen_score = hamming_gen_score(find(hamming_gen_score~=1));
    hamming_imp_score = scores(labels'~=labels);
    [EER_HASH_orig, mTSR, mFAR, mFRR, mGAR,threshold] =computeperformance(hamming_gen_score, hamming_imp_score, 0.001);  % isnightface 3.43 % 4.40 %
    
    
    
    Iset=nonzeros(triu( reshape(1:numel(hash_scores), size(hash_scores)) ));
    hash_distance=hash_scores(Iset);
    
    %     hash_distance=triu(hash_scores,1);
    %     hash_distance = hash_distance(hash_distance>0);
    
    %p_metric=
    
    scatter(orig_distance,hash_distance);
    ee=2;
    
    max_orig=round(max(orig_distance),ee)*10^ee;
    min_orig=round(min(orig_distance),ee)*10^ee;
    
    max_hash=round(max(hash_distance),ee)*10^ee;
    min_hash=round(min(hash_distance),ee)*10^ee;
    
    M = containers.Map({0},{[]});
    
    for i=1:length(orig_distance)
        indexx= uint32(round(orig_distance(i),ee)*10^ee);
        hashditance= uint32(round( hash_distance(i),ee)*10^ee);
        if isKey(M,indexx)
            M(indexx) = [M(indexx) hashditance];
        else
            M(indexx)=hashditance;
        end
        
        
    end
    
    remove(M,{0});
    
    Orig_x=min_orig:max_orig;
    Hash_y=min_hash:max_hash;
    
    p=zeros(length(Orig_x),length(Hash_y));
    
    keyset=M.keys;
    for i=1:length(Orig_x)
        indexx=Orig_x(i);
        if isKey(M,indexx)
            X=double(M(indexx));
            [a, b] = hist (X, unique(X));
            a=a./sum(a);
            tmp=zeros(1,length(Hash_y));
            for j=1:length(b)
                indexy=uint32(b(j));
                indexyy=find(Hash_y==indexy);
                tmp(indexyy)=a(j);
            end
            p(i,:)=tmp;
        else
            
            % p(i,:)=ones(1,length(Hash_y))./length(Hash_y);
            
        end
        
        
    end
    
    
    checkp=sum(p,2);
    [ind] = find(checkp>0.0);
    new_p=p(ind,:);
    
    checkp=sum(new_p,1);
    [ind] = find(checkp>0.0);
    new_p=new_p(:,ind);
    
    [C(cnt) r] = BlahutArimoto(new_p');
    SL= (100-EER_HASH_orig)*0.5 + (C(cnt)/log2(max(size(new_p,1),size(new_p,2))))*0.5;
    
    str_log=[num2str(dimensions),' ',num2str(EER_HASH_orig),' ',num2str(C(cnt)),' ',num2str(log2(max(size(new_p,1),size(new_p,2)))),' ',num2str(SL),'\r\n'];
    
    
    fid=fopen('logs/capacity_iom0723.log','a');
    fprintf(fid,str_log);
    fclose(fid);
    cnt = cnt+1;
end