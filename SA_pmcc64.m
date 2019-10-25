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

for i = 1:users
    for finger=1:8
        minutiaeTemplateFile = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(i), '_', num2str(finger),'.ist');
        twoPMccTemplateFile = strcat(pwd,'/data/FVC2002_DB2_A_ISO\', num2str(dimension), '_', num2str(i), '_', num2str(finger),'.2pmcc');
        template = BioLab.Biometrics.Mcc.Sdk.MccSdk.Create2PMccTemplateFromIsoTemplate(minutiaeTemplateFile,secretKey);
        
        BioLab.Biometrics.Mcc.Sdk.MccSdk.Save2PMccTemplateToBinaryFile(template, twoPMccTemplateFile);
        
    end
end


%% reconstruct the first one
for jjj=[1]
    opts.fingers=jjj;
    %% reconstruct the first one
    for i=1:100
        
        disp(['reconstructing ',num2str(i)])
        for fingers=1:jjj
            to_retrieve_hash_uri = strcat(pwd,'/data/FVC2002_DB2_A_ISO/', num2str(dimension), '_', num2str(i), '_', num2str(fingers),'.2pmcc');
            to_retrieve_hash{fingers} = BioLab.Biometrics.Mcc.Sdk.MccSdk.Load2PMccTemplateFromBinaryFile(to_retrieve_hash_uri);
        end
        
        %rng default % For reproducibility
        f_fitness = @(x)fitness_2pmcc(x,to_retrieve_hash,opts); % fitness function
        f_constr = []; % constrain function
        reconstruct_x = reconstruct(f_fitness,f_constr,opts);
        save(['data/pmcc/2pmcc_reconstruct_',num2str(i),'_',num2str(jjj),'_',num2str(dimension),'.mat'],'reconstruct_x');
    end
end


