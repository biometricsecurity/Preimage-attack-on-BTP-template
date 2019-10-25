clear all;
close all;

addpath('matlab_tools');

% addpath('MccSdk v2.0/SourceCode/MATLAB')



% Makes the MCC SDK visible to MATLAB
% Change path for MccSdk.dll when necessary
NET.addAssembly(fullfile('c:/MccSdk.dll'));
% BioLab.Biometrics.Mcc.Sdk.MccSdk.SetMccMatchParameters('C:/project source file/MCC CompareMccSdk v2.0/Sdk/MccPaperMatchParameters.xml');
twoPMccEnrollParamFile = 'MccSdk v2.0/Sdk/PMccPaperEnrollParameters.xml';
pMccEnrollParamFile = 'MccSdk v2.0/Sdk/PMccPaperEnrollParameters.xml';
pMccMatchParamFile = 'MccSdk v2.0/Sdk/PMccPaperMatchParameters.xml';

users=100;
opts.dX=50*3;
dimension=16;  %16 32 64 128
opts.dimension=dimension;
%

klTransformFile = strcat('MccSdk v2.0/Sdk/PMCC', num2str(dimension), '.txt');  %16 32 64 128
BioLab.Biometrics.Mcc.Sdk.MccSdk.SetPMccEnrollParameters(pMccEnrollParamFile, klTransformFile);
BioLab.Biometrics.Mcc.Sdk.MccSdk.SetPMccMatchParameters(pMccMatchParamFile);



users=100;
% select 1-3 samples of each user for training data
for i = 1:users
    for finger=1:8
        file1 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(i), '_', num2str(finger),'.ist');
        template{i,finger}=BioLab.Biometrics.Mcc.Sdk.MccSdk.CreateMccTemplateFromIsoTemplate(file1);
    end
end

gen = [];
for i = 1:100
    combination = nchoosek(1:8, 2);
    
    for j = 1:length(combination)
        file1 = combination(j,:);
        
        template1 = template{i,file1(1)};
        
        template2 =template{i,file1(2)};
        
        %Matches the two MCC Templates.
        score = BioLab.Biometrics.Mcc.Sdk.MccSdk.MatchMccTemplates(template1, template2);
        
        gen = [gen; score];
    end
end

imp = [];
combination = nchoosek(1:100, 2);
for i = 1:length(combination)
    files = combination(i,:);
    
    
    template1 = template{file1(1),1};
    
    template2 =template{file1(2),1};
    
    %Matches the two MCC Templates.
    score = BioLab.Biometrics.Mcc.Sdk.MccSdk.MatchMccTemplates(template1, template2);
    
    
    %     similiraty=totalnumbs/totalnumbm;
    imp = [imp; score];
end
[EER_HASH_orig, mTSR, mFAR, mFRR, mGAR] = computeperformance(gen, imp, 0.001);

orig_distance = [gen;imp];
orig_distance = 1-orig_distance;

cnt=1;
for dimension=[16 32 64 128]
    
    
    klTransformFile = strcat('MccSdk v2.0/Sdk/PMCC', num2str(dimension), '.txt');  %16 32 64 128
    BioLab.Biometrics.Mcc.Sdk.MccSdk.SetPMccEnrollParameters(pMccEnrollParamFile, klTransformFile);
    BioLab.Biometrics.Mcc.Sdk.MccSdk.SetPMccMatchParameters(pMccMatchParamFile);

    
    gen = [];
    for i = 1:100
        combination = nchoosek(1:8, 2);
        
        for j = 1:length(combination)
            file1 = combination(j,:);
            
            template1 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(i), '_', num2str(file1(1)),'.pmcc');
            template2 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(i), '_', num2str(file1(2)),'.pmcc');
            %         %Matches the two MCC Templates.
            Template1 = BioLab.Biometrics.Mcc.Sdk.MccSdk.LoadPMccTemplateFromBinaryFile(template1);
            Template2 = BioLab.Biometrics.Mcc.Sdk.MccSdk.LoadPMccTemplateFromBinaryFile(template2);
            %
            score = BioLab.Biometrics.Mcc.Sdk.MccSdk.MatchPMccTemplates(Template1,Template2 );
            
            gen = [gen; score];;
            
        end
    end
    
    imp = [];
    combination = nchoosek(1:100, 2);
    for i = 1:length(combination)
        files = combination(i,:);
        
        
        template1 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(files(1)), '_', num2str(1),'.pmcc');
        template2 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(files(2)), '_', num2str(1),'.pmcc');
        Template1 = BioLab.Biometrics.Mcc.Sdk.MccSdk.LoadPMccTemplateFromBinaryFile(template1);
        Template2 = BioLab.Biometrics.Mcc.Sdk.MccSdk.LoadPMccTemplateFromBinaryFile(template2);
        score = BioLab.Biometrics.Mcc.Sdk.MccSdk.MatchPMccTemplates(Template1, Template2);
        imp = [imp; score];
        
    end
    [EER_HASH_pmcc, mTSR, mFAR, mFRR, mGAR] = computeperformance(gen, imp, 0.001);

    hash_distance= [gen;imp];
    hash_distance=1-hash_distance;

    
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
    str_log=[num2str(dimension),' ',num2str(EER_HASH_orig),' ',num2str(EER_HASH_pmcc),' ',num2str(C(cnt)),' ',num2str(log2(max(size(new_p,1),size(new_p,2)))),' ',num2str(SL),'\r\n'];
    
    
    fid=fopen('logs/capacity_pmcc.log','a');
    fprintf(fid,str_log);
    fclose(fid);
    cnt = cnt+1;
end
