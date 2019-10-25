%%%%%%%%%%%Genuine%%%%%%%%%% �������
clear all
addpath('matlab_tools');
addpath_recurse('matlab_tools')
addpath_recurse('btp')

load('data/iriscode from yenlung/templates.mat')
load('data/iriscode from yenlung/labels.mat')
%
uniqulabels=unique(labels);
indexs=[];
for i=1:length(uniqulabels)
    [value, inde]=find(labels==uniqulabels(i));
    indexs=[indexs inde(1)];
end

M = containers.Map({0},{[]});
for i=1:length(labels)
    if isKey(M,labels(i))
        M(labels(i)) =[ M(labels(i)) i];
    else
        M(labels(i)) = [i];
    end
end
remove(M,0);

Performance=[];

% L=10; W=20;
gen=[]; genclm=[];
for kk=1:length(uniqulabels)
    thisuserlabels=  M(uniqulabels(kk));
    if ( length(thisuserlabels)>5)
        combination = nchoosek(1:length(M(uniqulabels(kk))), 2);
        
        for ii=1:length(combination)
            comb=combination(ii,:);
            Template1 = templates(thisuserlabels(1)+comb(1)-1,:);
            Template2 = templates(thisuserlabels(1)+comb(2)-1,:);
            
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
        end
    end
end


%%%%%%%%%%%Imposter%%%%%%%%%%





imp=[];impclm=[];
combination = nchoosek(uniqulabels, 2);

for k = 1:length(combination)
    k
    
    
    comb=combination(k,:);
    userA=   M(comb(1)) ;
    userB=   M(comb(2)) ;
    Template1 = templates(userA(1),:);
    Template2 = templates(userB(1),:);
    
    
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
    
    
    
    
    
    
end


[EER, mTSR, mFAR, mFRR, mGAR] = computeperformance(imp, gen, 0.0001); % 0.63%  7.48 %


