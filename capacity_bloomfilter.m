%%%%%%%%%%%Genuine%%%%%%%%%%
clear all
addpath('matlab_tools');
addpath_recurse('btp')


Performance=[];

% L=10; W=20;
gen=[]; genclm=[];
combination = nchoosek(1:18, 2);

for k = 1:248
    k
    
    for ii=1:length(combination)
        comb=combination(ii,:);
        
        
        No_user = sprintf('%03d', k);
        Selected_template1 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',No_user,'_', sprintf('%02d', (comb(1))), '.txt');
        Selected_template2 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',No_user,'_', sprintf('%02d', (comb(2))), '.txt');
        
        
        if (exist(Selected_template1, 'file') && exist(Selected_template2, 'file') )
            
            Template1 = load(Selected_template1);
            Template2 = load(Selected_template2);
            
            score=[];column_score_all=[];
            for ss=-2: 2
                %              Template1_shifted=shiftbits(Template1, ss,0.5);
                Template2_shifted=shiftbits(Template2, ss,0.5);
                column_score=sum(Template2_shifted~=Template1);
                HD= sum(column_score);
                score=[score;HD/numel(Template2_shifted)];
                column_score_all=[column_score_all;max(column_score)];
            end
            
            gen=[gen;min(score)];genclm=[genclm;max(column_score_all)];
        else
            % 		fprintf('File %s does not exist./n', jpgFileName);
            continue;
        end
        
        
    end
end

%%%%%%%%%%%Imposter%%%%%%%%%%
imp=[];impclm=[];
combination = nchoosek(1:248, 2);

for k = 1:length(combination)
    k
    
    
    comb=combination(k,:);
    
    
    No_user = sprintf('%03d', k);
    Selected_template1 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',sprintf('%03d', (comb(1))),'_01', '.txt');
    Selected_template2 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',sprintf('%03d', (comb(2))),'_01', '.txt');
    
    
    if (exist(Selected_template1, 'file') && exist(Selected_template2, 'file') )
        Template1 = load(Selected_template1);
        Template2 = load(Selected_template2);
        
        score=[];column_score_all=[];
        for ss=-2: 2
            %              Template1_shifted=shiftbits(Template1, ss,0.5);
            Template2_shifted=shiftbits(Template2, ss,0.5);
            %              xdiff=abs(Template1-Template2_shifted);
            
            column_score=sum(Template2_shifted~=Template1);
            HD= sum(column_score);
            column_score_all=[column_score_all;max(column_score)];
            score=[score;HD/numel(Template2_shifted)];
            
        end
        
        imp=[imp;min(score)];impclm=[impclm;max(column_score_all)];
    else
        % 		fprintf('File %s does not exist./n', jpgFileName);
        continue;
    end
    
    
    
    
    
    
end

[EER_orig, mTSR, mFAR, mFRR, mGAR] = computeperformance(imp, gen, 0.0001);
orig_distance =[1-imp; 1-gen];

%% reconstruct the first one
% I want the first of each user
% 3:10
cnt=1;
for bitss=8:10
    
    opts.N_BITS_BF=bitss; %3 -10 word size
    opts.N_WORDS_BF=power(2,6); % block length , how many words in one block 5-9
    opts.H=20;
    opts.W=512;
    opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
    opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
    opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
    opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));
    
    
    
    Performance=[];
    
    % L=10; W=20;
    gen=[]; genclm=[];
    combination = nchoosek(1:18, 2);
    
    for k = 1:248
        k
        
        for ii=1:length(combination)
            comb=combination(ii,:);
            
            
            No_user = sprintf('%03d', k);
            Selected_template1 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',No_user,'_', sprintf('%02d', (comb(1))), '.txt');
            Selected_template2 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',No_user,'_', sprintf('%02d', (comb(2))), '.txt');
            
            
            if (exist(Selected_template1, 'file') && exist(Selected_template2, 'file') )
                
                Template1 = load(Selected_template1);
                Template2 = load(Selected_template2);
                BFs_fromTemplate1 = extract_BFs_from_Iriscode_features(Template1,opts);
                BFs_fromTemplate2 = extract_BFs_from_Iriscode_features(Template2,opts);
                score = 1-bloomfilter_hamming(BFs_fromTemplate1,BFs_fromTemplate2,opts);
                
                
                gen=[gen;score];
                
                
                
            end
        end
    end
    %%%%%%%%%%%Imposter%%%%%%%%%%
    imp=[];impclm=[];
    combination = nchoosek(1:248, 2);
    
    for k = 1:length(combination)
        k
        
        
        comb=combination(k,:);
        
        
        No_user = sprintf('%03d', k);
        Selected_template1 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',sprintf('%03d', (comb(1))),'_01', '.txt');
        Selected_template2 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',sprintf('%03d', (comb(2))),'_01', '.txt');
        
        
        if (exist(Selected_template1, 'file') && exist(Selected_template2, 'file') )
            Template1 = load(Selected_template1);
            Template2 = load(Selected_template2);
            
            Template1 = load(Selected_template1);
            Template2 = load(Selected_template2);
            BFs_fromTemplate1 = extract_BFs_from_Iriscode_features(Template1,opts);
            BFs_fromTemplate2 = extract_BFs_from_Iriscode_features(Template2,opts);
            score = 1-bloomfilter_hamming(BFs_fromTemplate1,BFs_fromTemplate2,opts);
            
            imp=[imp;score];
            
            
        end
        
    end
    [EER_HASH, mTSR, mFAR, mFRR, mGAR,threshold] =computeperformance(gen, imp, 0.001);  % isnightface 3.43 % 4.40 %
    hash_distance =[1-imp; 1-gen];
    
    
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
    SL= (100-EER_HASH)*0.5 + (C(cnt)/log2(max(size(new_p,1),size(new_p,2))))*0.5;
    
    str_log=[num2str(bitss),' ',num2str(EER_HASH),' ',num2str(C(cnt)),' ',num2str(log2(max(size(new_p,1),size(new_p,2)))),' ',num2str(SL),'/r/n'];
    
    
    fid=fopen('logs/capacity_bf0723.log','a');
    fprintf(fid,str_log);
    fclose(fid);
    cnt = cnt+1;
    
end
