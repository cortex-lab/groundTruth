

function runComparisonAndUpdateResults(setName, algorithmName, submissionRootDir, answersRootDir)

% load ground truth
datFilename = [];
cluFile = dir(fullfile(answersRootDir, setName, '*.clu.1'));
gtClu = LoadClu(fullfile(answersRootDir, setName, cluFile.name));
resFile = dir(fullfile(answersRootDir, setName, '*.res.1'));
fid = fopen(fullfile(answersRootDir, setName, resFile.name), 'r'); 
gtRes = int32(fscanf(fid, '%d')); 
fclose(fid);

% load submission results
[testRes, testClu] =  readResCluTxt(fullfile(submissionRootDir, setName, [algorithmName '_' setName]));
numSpikes = length(testClu);
numClusters = length(unique(testClu));

% run comparison
entryDir = fullfile(submissionRootDir, setName, [algorithmName '_' setName '_']);
[allScores, allFPs, allMisses, allMerges] = compareClustering(gtClu, gtRes, testClu, testRes, datFilename, entryDir);


% save the scores
save([entryDir 'scores.mat'], 'allScores', 'allFPs', 'allMisses', 'allMerges', 'numSpikes', 'numClusters');


% run the plot generation 
plotOverallSummary(submissionRootDir);
plotSetSummary(submissionRootDir, setName);

% write html update
writeHtml

end

