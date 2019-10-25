function [distance] = fitness_bloomfilter(x, hashcode,opts)

[transformed_data0] = extract_BFs_from_Iriscode_features(x,opts);

% [distance] = bloomfilter_hamming(transformed_data0,hashcode,opts); %
% original distance
[distance] = pdist2(hashcode,transformed_data0,'Hamming');
% [distance] = 1 - matching_IoM(hashcode,transformed_data0);

end