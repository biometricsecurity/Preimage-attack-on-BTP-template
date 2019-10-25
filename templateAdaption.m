function [template] = templateAdaption(minutiatepoints,opts)
%350 40
minutiatepoints = abs(minutiatepoints);
numberofpoints = length(minutiatepoints)/3;

str_log=[num2str(350),'\r\n',num2str(350),'\r\n',num2str(500),'\r\n',num2str(numberofpoints),'\r\n'];

for i=1:numberofpoints
    str_log=[str_log, num2str(ceil(minutiatepoints((i-1)*3+1:(i-1)*3+2)*350)),' ',num2str(ceil(abs(minutiatepoints((i-1)*3+3)*350))*pi/180),'\r\n'];
end


uri=strcat('logs/tmp', num2str(opts.dimension), num2str(opts.dX), num2str(opts.fingers), '.txt');

fid=fopen(uri,'w');
fprintf(fid,str_log);
fclose(fid);

template = BioLab.Biometrics.Mcc.Sdk.MccSdk.Create2PMccTemplateFromTextTemplate(uri,opts.secretKey);

end