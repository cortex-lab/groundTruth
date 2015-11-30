
% script to run an example compareClustering

cd V:\nick\GroundTruth\set1

setName = '20141202_all_emptyStatic';

clu = LoadClu([setName '.clu.1']);
fid = fopen([setName '.res.1'], 'r'); 
res = int32(fscanf(fid, '%d')); 
fclose(fid);

kwikFile = 'testOutput.kwik';
clu2 = h5read(kwikFile, '/channel_groups/1/spikes/clusters/main');
TimeSamples = h5read(kwikFile, '/channel_groups/1/spikes/time_samples');
res2 = int32(TimeSamples);


compareClustering(clu, res, clu2, res2, [setName '.dat'])