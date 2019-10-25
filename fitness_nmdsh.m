function [distance] = fitness_nmdsh(x, hashcode,SHparamNew1)

[B1,U1] = compressMDSH(x, SHparamNew1);
hashed_code=double(U1>0);

distcc=[];
for a=1:size(hashcode,1)
    distcc=[distcc 1 - matching_IoM(hashcode(a,:),hashed_code)];
end

distance=mean(distcc);


end