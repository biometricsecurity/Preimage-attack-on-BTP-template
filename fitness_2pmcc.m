function [distance] = fitness_2pmcc(x, hashcode,opts)


[new_template] = templateAdaption(x,opts);

distcc=[];
for a=1:size(hashcode,2)
    distcc=[distcc 1-BioLab.Biometrics.Mcc.Sdk.MccSdk.Match2PMccTemplates(new_template,hashcode{a})];
end

distance=mean(distcc);


end