% % % SA_BioHashingResistance
% % % SA_BioHashingResistance
% % % SA_BioHashingResistance
% % SA_BioHashingResistance
% % 
% % % SA_IoM_noconstrResistance
% % % SA_IoM_noconstrResistance
% % % SA_IoM_noconstrResistance
% % SA_IoM_noconstrResistance
% % 
% % SA_BioHashingConstrResistance
% % SA_BioHashingConstrResistance
% % SA_BioHashingConstrResistance
% % SA_BioHashingConstrResistance

tic
for i=1:100000
    hist= rand(1,8)-0.5>0;
    location =sum(power(2,find(hist>0)-1));
    
end
toc

tic
for i=1:100000
    hist= rand(1,8)-0.5>0;
    location =bi2de(hist',2);
end
toc
