# On-the-Reliability-of-Cancelable-Biometrics-Revisit-the-Irreversibility

# Usage based on BioHashing example

# Fitness function
fitness_biohashing.m
```bash
function [distance] = fitness_biohashing(x, hashcode,opts)


[transformed_data] = biohashing(x,opts.model);

% [distance] = bloomfilter_hamming(transformed_data0,hashcode,opts); %
% original distance
distcc=[];
for a=1:size(hashcode,1)
    distcc=[distcc 1 - matching_IoM(hashcode(a,:),transformed_data)];
end

distance=mean(distcc);


end
```

2
​
