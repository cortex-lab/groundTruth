

function [missRate, fpRate] = evaluateGroundTruth(spikeTimes, clusterIDs, gtClusterID, gtSpikeTimes)
% function [missRate, fpRate] = evaluateGroundTruth(spikeTimes, clusterIDs, gtClusterID, gtSpikeTimes)
%
% Evaluates how successful a sorting was when you know the ID of the
% cluster that corresponds to the ground truth, as when you did manual
% sorting then visually identified which waveform corresponds to the ground
% truth one. 
%
% Inputs: 
% - spikeTimes - vector of all spike times in the sorting, in seconds
% (spike_times.npy, but converted from samples to seconds)
% - clusterIDs - vector of the cluster labels of all of those spikes
% (spike_clusters.npy)
% - gtClusterID - a single number that is the ID of the cluster you
% identified (in phy, e.g.) as corresponding to the GT neuron
% - gtSpikeTimes - vector of spike times of the GT neuron, measured in a
% ground-truth manner, in seconds
%
% Outputs:
% - missRate - proportion of gtSpikeTimes that were not found in the sorted
% cluster
% - fpRate - proportion of spikes in the sorted cluster that were not part
% of the GT spikes
%
% Requires https://github.com/cortex-lab/groundTruth. 
% You must compile the mex file CCGHeart as well. 
% 

% select the sorted spike times in question, the ones from the identified
% cluster
sortedST = spikeTimes(clusterIDs==gtClusterID); 

nSorted = numel(sortedST);
nGT = numel(gtSpikeTimes);

Fs = 30000; % need to convert the times to samples for the algorithm below
sortedSTsamps = int32(ceil(sortedST*Fs)); 
gtSTsamps = int32(ceil(gtSpikeTimes*Fs)); 
[missRate, fpRate] = compareSpikeTimes(sortedSTsamps, gtSTsamps);

fprintf(1, 'There were %d ground truth spikes, and sorted cluster %d missed %.2f%% of them.\n', ...
    nGT, gtClusterID, missRate*100);
fprintf(1, 'There were %d spikes in sorted cluster %d, and %.2f%% of these were false positives.\n', ...
    nSorted, gtClusterID, fpRate*100);

return;

%% wrapper given a phy directory

% specify myPhyDir, gtClusterID
% myPhyDir = ...
% gtClusterID = ...

pars = loadParamsPy(fullfile(myPhyDir, 'params.py'));
ss = readNPY(fullfile(myPhyDir, 'spike_times.npy'));
st = double(ss)/pars.sample_rate;
clu = readNPY(fullfile(myPhyDir, 'spike_clusters.npy'));

% load gtSpikeTimes here!
% gtST = ...

[missRate, fpRate] = evaluateGroundTruth(st, clu, gtClusterID, gtST);



%% test cases

st = [1 2 3 4 5]; clu = [1 1 1 2 1]; gtClu = 1; gtST = [1 2 3];
[missRate, fpRate] = evaluateGroundTruth(st, clu, gtClu, gtST)
% 0 miss, 0.25 fp

%%
st = [1 2 3 4 5]; clu = [1 1 1 2 1]; gtClu = 1; gtST = [1 2 3 4];
[missRate, fpRate] = evaluateGroundTruth(st, clu, gtClu, gtST)
% 0.25 miss, 0.25 fp

%%
st = [1 2 3 4 5]; clu = [1 1 2 2 1]; gtClu = 1; gtST = [1 2 3 4];
[missRate, fpRate] = evaluateGroundTruth(st, clu, gtClu, gtST)
% 0.5 miss, 0.33 fp
