
function [res, clu] =  readResCluTxt(filebase)

fid = fopen([filebase '_spikeTimes.txt'], 'r'); 
res = int32(fscanf(fid, '%d')); 
fclose(fid);

fid = fopen([filebase '_spikeClusters.txt'], 'r'); 
clu = int32(fscanf(fid, '%d')); 
fclose(fid);