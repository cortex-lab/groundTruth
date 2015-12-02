

function convertKilosortToTxt(outputFilebase, rez)

Clu = int32(rez.st3pos(:,2));
Res = int32(rez.st3pos(:,1));

fid = fopen([outputFilebase '_spikeTimes.txt'], 'w');
fprintf(fid,'%d\n', Res(:));
fclose(fid);

fid = fopen([outputFilebase '_spikeClusters.txt'], 'w');
fprintf(fid,'%d\n', Clu(:));
fclose(fid);