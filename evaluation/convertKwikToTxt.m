

function convertKwikToTxt(outputFilebase, kwikFile)


Res = int32(h5read(kwikFile, '/channel_groups/1/spikes/time_samples'));

fid = fopen([outputFilebase '_spikeTimes.txt'], 'w');
fprintf(fid,'%d\n', Res(:));
fclose(fid);

Clu = h5read(kwikFile, '/channel_groups/1/spikes/clusters/main');

fid = fopen([outputFilebase '_spikeClusters.txt'], 'w');
fprintf(fid,'%d\n', Clu(:));
fclose(fid);