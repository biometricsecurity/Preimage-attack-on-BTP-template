function [mu,sigma] = mynormfit(hamming_gen_score)
%MYNORMFIT Summary of this function goes here
%   Detailed explanation goes here

data = hamming_gen_score;%???  
[mu,sigma]=normfit(data);%estimate of the mean and standard deviation in data  
[y,x]=hist(data,6);%creates a histogram bar plot of data,sorts data into the number of bins specified by nbins  
%return the categorical levels correponding to each count in N  
bar(x,y,'FaceColor','r','EdgeColor','w');box off  
xlim([mu-3*sigma,mu+3*sigma]) % sets the axis limits in the current axes to the specified values  
a2=axes;  
% computes the pdf at each of the values in X using the normal distribution  
% with mean and standard deviation sigma.  
ezplot(@(x)normpdf(x,mu,sigma),[mu-3*sigma,mu+3*sigma])  
set(a2,'box','off','yaxislocation','right','color','none')  
title '??????????????????'  


end

