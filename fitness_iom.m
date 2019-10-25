function [distance] = fitness_iom(x, hashcode,opts)
db_data.X=x';
[all_code, ~] = IoM(db_data, opts, opts.model);

transformed_data = all_code.Hx';
% [distance] = bloomfilter_hamming(transformed_data0,hashcode,opts); %
% original distance
distcc=[];
for a=1:size(hashcode,1)
    distcc=[distcc 1 - matching_IoM(hashcode(a,:),transformed_data)];
end

distance=mean(distcc);


end