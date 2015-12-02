
function convertResCluToTxt(outputFilebase, resCluBase)


Clu = LoadClu([resCluBase '.clu.1']);
fid = fopen([outputFilebase '_spikeClusters.txt'], 'w');
fprintf(fid,'%d\n', Clu(:));
fclose(fid);

% fid = fopen([outputFilebase '_spikeTimes.txt'], 'w');
% fprintf(fid,'%d\n', Res(:));
% fclose(fid);

% just copy the res file; it's already correct
copyfile([resCluBase '.res.1'], [outputFilebase '_spikeTimes.txt']);

