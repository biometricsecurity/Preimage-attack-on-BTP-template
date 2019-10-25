%%%%%%%%%%%Genuine%%%%%%%%%%
clear all
addpath('matlab_tools');
addpath_recurse('btp')

opts.N_BITS_BF=10; %3 -10 word size
opts.N_WORDS_BF=power(2,6); % block length , how many words in one block 5-9
opts.H=20;
opts.W=512;
opts.N_BF_Y = floor(opts.H/opts.N_BITS_BF);
opts.N_BF_X = floor(opts.W/opts.N_WORDS_BF);
opts.BF_N_BLOCKS= opts.N_BF_X *  opts.N_BF_Y; % how many blocks for one template
opts.BF_SIZE = uint32(power(2, opts.N_BITS_BF));

Performance=[];

% L=10; W=20;
gen=[]; genclm=[];
combination = nchoosek(1:18, 2);

for k = 1:248
    k
    
    for ii=1:length(combination)
        comb=combination(ii,:);
        
        
        No_user = sprintf('%03d', k);
        Selected_template1 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',No_user,'_', sprintf('%02d', (comb(1))), '.txt');
        Selected_template2 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',No_user,'_', sprintf('%02d', (comb(2))), '.txt');
        
        
        if (exist(Selected_template1, 'file') && exist(Selected_template2, 'file') )
            
            Template1 = load(Selected_template1);
            Template2 = load(Selected_template2);
            
            [bf_templates1] = bloomfilter(Template1,opts);
            [bf_templates2] = bloomfilter(Template2,opts);
%             [distane] = bloomfilter_hamming(bf_templates1,bf_templates2,opts);
            [distane] = hamming_distance(bf_templates1,bf_templates2);
            %          distane = pdist2(bf_templates1,bf_templates2,'Hamming');
            gen=[gen;distane];
        else
            % 		fprintf('File %s does not exist./n', jpgFileName);
            continue;
        end
        
        
    end
end




%%%%%%%%%%%Imposter%%%%%%%%%%





imp=[];impclm=[];
combination = nchoosek(1:248, 2);

for k = 1:length(combination)
    k
    
    
    comb=combination(k,:);
    
    
    No_user = sprintf('%03d', k);
    Selected_template1 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',sprintf('%03d', (comb(1))),'_01', '.txt');
    Selected_template2 = strcat(pwd,'/data/iriscode from yenlung/FullCasia_intv__20x512(1324)/',sprintf('%03d', (comb(2))),'_01', '.txt');
    
    
    if (exist(Selected_template1, 'file') && exist(Selected_template2, 'file') )
        Template1 = load(Selected_template1);
        Template2 = load(Selected_template2);
        [bf_templates1] = bloomfilter(Template1,opts);
        [bf_templates2] = bloomfilter(Template2,opts);
%         [distane] = bloomfilter_hamming(bf_templates1,bf_templates2,opts);
        %        distane = pdist2(bf_templates1,bf_templates2,'Hamming');
                    [distane] = hamming_distance(bf_templates1,bf_templates2);

        
        imp=[imp;distane];
    else
        % 		fprintf('File %s does not exist./n', jpgFileName);
        continue;
    end
    
    
end


[EER, mTSR, mFAR, mFRR, mGAR] = computeperformance(imp, gen, 0.0001); % 14%  11.48 % 10-20.79 % 3-51.54 % 6-27.48 % 8-22.52% 10-20.79 %
