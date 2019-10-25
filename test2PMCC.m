addpath('matlab_tools')
% addpath('D:\UNISS-BAK\xingbo\20190717-SA-MCC\MccSdk v2.0\SourceCode\MATLAB')



% Makes the MCC SDK visible to MATLAB
% Change path for MccSdk.dll when necessary
NET.addAssembly(fullfile('c:\MccSdk.dll'));
% BioLab.Biometrics.Mcc.Sdk.MccSdk.SetMccMatchParameters('C:\project source file\MCC Compare\MccSdk v2.0\Sdk\MccPaperMatchParameters.xml');
klTransformFile = 'MccSdk v2.0\Sdk\PMCC64.txt';
twoPMccEnrollParamFile = 'MccSdk v2.0\Sdk\PMccPaperEnrollParameters.xml';
pMccEnrollParamFile = 'MccSdk v2.0\Sdk\PMccPaperEnrollParameters.xml';
pMccMatchParamFile = 'MccSdk v2.0\Sdk\PMccPaperMatchParameters.xml';
secretKey=123;
parameterC =64;
users=100;
% 

BioLab.Biometrics.Mcc.Sdk.MccSdk.Set2PMccEnrollParameters(twoPMccEnrollParamFile, klTransformFile, parameterC, true);
BioLab.Biometrics.Mcc.Sdk.MccSdk.Set2PMccMatchParameters(pMccMatchParamFile);

for i = 1:users
    for finger=1:8
        minutiaeTemplateFile = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(i), '_', num2str(finger),'.ist');
        twoPMccTemplateFile = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(i), '_', num2str(finger),'.2pmcc');
        outputFile = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(i), '_', num2str(finger),'.out');
        template = BioLab.Biometrics.Mcc.Sdk.MccSdk.Create2PMccTemplateFromIsoTemplate(minutiaeTemplateFile,secretKey);
        
        BioLab.Biometrics.Mcc.Sdk.MccSdk.Save2PMccTemplateToBinaryFile(template, twoPMccTemplateFile);
        
    end
end


gen = [];
for i = 1:100
    combination = nchoosek(1:8, 2);
    
    for j = 1:length(combination)
        file1 = combination(j,:);
        
        
        
        template1 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(i), '_', num2str(file1(1)),'.2pmcc');
        template2 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(i), '_', num2str(file1(2)),'.2pmcc');
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
    
    
    template1 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(files(1)), '_', num2str(1),'.2pmcc');
    template2 = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(files(2)), '_', num2str(1),'.2pmcc');
    template1 = BioLab.Biometrics.Mcc.Sdk.MccSdk.Load2PMccTemplateFromBinaryFile(template1);
    template2 = BioLab.Biometrics.Mcc.Sdk.MccSdk.Load2PMccTemplateFromBinaryFile(template2);
    score = BioLab.Biometrics.Mcc.Sdk.MccSdk.Match2PMccTemplates(template1, template2);
    imp = [imp; score];
    
end


[EER, mTSR, mFAR, mFRR, mGAR] = computeperformance(gen, imp, 0.001);


