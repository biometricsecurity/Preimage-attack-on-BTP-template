function [distance] = fitness_bloomfilter_twohashcode(x, hashcode,opts)

[transformed_data0] = extract_BFs_from_Iriscode_features(x,opts);

% [distance] = bloomfilter_hamming(transformed_data0,hashcode,opts); %
% original distance
distcc=[];
for a=1:size(hashcode,1)
    distcc=[distcc pdist2(hashcode(a,:),transformed_data0,'Hamming')];
end

distance=mean(distcc);
% [distance] = 1 - matching_IoM(hashcode,transformed_data0);

end