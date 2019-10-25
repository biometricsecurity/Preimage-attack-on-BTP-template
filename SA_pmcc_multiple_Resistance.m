addpath('matlab_tools')
% addpath('D:\UNISS-BAK\xingbo\20190717-SA-MCC\MccSdk v2.0\SourceCode\MATLAB')



% Makes the MCC SDK visible to MATLAB
% Change path for MccSdk.dll when necessary
NET.addAssembly(fullfile('c:\MccSdk.dll'));
% BioLab.Biometrics.Mcc.Sdk.MccSdk.SetMccMatchParameters('C:\project source file\MCC Compare\MccSdk v2.0\Sdk\MccPaperMatchParameters.xml');
twoPMccEnrollParamFile = 'MccSdk v2.0\Sdk\PMccPaperEnrollParameters.xml';
pMccEnrollParamFile = 'MccSdk v2.0\Sdk\PMccPaperEnrollParameters.xml';
pMccMatchParamFile = 'MccSdk v2.0\Sdk\PMccPaperMatchParameters.xml';
secretKey=123;
% 


users=100;
opts.dX=50*3;
dimension=64;  %16 32 64 128
opts.dimension=dimension;
opts.secretKey=secretKey;
%
parameterC =dimension;

klTransformFile = strcat('MccSdk v2.0/Sdk/PMCC', num2str(dimension), '.txt');  %16 32 64 128

BioLab.Biometrics.Mcc.Sdk.MccSdk.Set2PMccEnrollParameters(twoPMccEnrollParamFile, klTransformFile, parameterC, true);
BioLab.Biometrics.Mcc.Sdk.MccSdk.Set2PMccMatchParameters(pMccMatchParamFile);


%% %%% original

gen = [];
for i = 1:100
    combination = nchoosek(1:8, 2);
    
    for j = 1:length(combination)
        file1 = combination(j,:);
        
        
        
        template1 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(i), '_', num2str(file1(1)),'.2pmcc');
        template2 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(i), '_', num2str(file1(2)),'.2pmcc');
%         %Matches the two MCC Templates.
        Template1 = BioLab.Biometrics.Mcc.Sdk.MccSdk.LoadPMccTemplateFromBinaryFile(template1);
        Template2 = BioLab.Biometrics.Mcc.Sdk.MccSdk.LoadPMccTemplateFromBinaryFile(template2);
%         
        score = BioLab.Biometrics.Mcc.Sdk.MccSdk.Match2PMccTemplates(Template1,Template2 );
        
        
        %     similiraty=totalnumbs/totalnumbm;
        gen = [gen; score];;
        
    end
end

imp = [];
combination = nchoosek(1:100, 2);
for i = 1:length(combination)
    files = combination(i,:);
    
    
    template1 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(files(1)), '_', num2str(1),'.2pmcc');
    template2 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(files(2)), '_', num2str(1),'.2pmcc');
    template1 = BioLab.Biometrics.Mcc.Sdk.MccSdk.Load2PMccTemplateFromBinaryFile(template1);
    template2 = BioLab.Biometrics.Mcc.Sdk.MccSdk.Load2PMccTemplateFromBinaryFile(template2);
    score = BioLab.Biometrics.Mcc.Sdk.MccSdk.Match2PMccTemplates(template1, template2);
    imp = [imp; score];
    
end


[EER_HASH_orig, mTSR, mFAR, mFRR, mGAR,threshold] =computeperformance(gen, imp, 0.001);  % isnightface 3.43 % 4.40 %
[FAR_orig,FRR_orig] = FARatThreshold(gen,imp,threshold);

%%

for jjj=[1 3 5 ]
    
    
    
    approxmate_gen = [];
    for i = 1:100
        for j = jjj+1:8
            
            template1_uri = strcat(pwd,'/data/pmcc/pmcc_reconstruct_', num2str(i), '_', num2str(jjj),'_', num2str(dimension),'.mat');
            load(template1_uri);
            Template1 =templateAdaption(reconstruct_x);
            template2 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(i), '_', num2str(j),'.2pmcc');
            %         %Matches the two MCC Templates.
            Template2 = BioLab.Biometrics.Mcc.Sdk.MccSdk.LoadPMccTemplateFromBinaryFile(template2);
            %
            score = BioLab.Biometrics.Mcc.Sdk.MccSdk.MatchPMccTemplates(Template1,Template2 );
            
            approxmate_gen = [approxmate_gen; score];
            
        end
    end
    
    [FAR_attack,FRR_attack] = FARatThreshold(gen,approxmate_gen,threshold);
    
    
    str_log=[num2str(jjj),' ',num2str(threshold),' ',num2str(EER_HASH_orig),' ',num2str(FAR_orig*100),' ',num2str(FAR_attack*100),'\r\n'];
    disp(str_log);
    
    
    fid=fopen('logs/2pmcc_multi.log','a');
    fprintf(fid,str_log);
    fclose(fid);
    
end

