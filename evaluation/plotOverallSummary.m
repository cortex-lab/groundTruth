
function plotOverallSummary(rootDir)

sets = {'set1', 'set2', 'set3', 'set4', 'set5', 'set6'};
algorithms = {'phy', 'spykingCircus', 'globalSuper', 'kiloSort'};

% rootDir = 'V:\nick\GroundTruth\';

finalScore = nan(length(sets), length(algorithms));
fpRate = nan(length(sets), length(algorithms));
missRate = nan(length(sets), length(algorithms));
numMerges = nan(length(sets), length(algorithms));
initialScore = nan(length(sets), length(algorithms));
nSpikes = nan(length(sets), length(algorithms));
nClusters = nan(length(sets), length(algorithms));

for s = 1:length(sets)
    for a = 1:length(algorithms)
        entryFile = fullfile(rootDir, sets{s}, [algorithms{a} '_' sets{s} '_scores.mat']);
        if exist(entryFile)
            clear numSpikes numClusters
            load(entryFile)
            
            if ~exist('numSpikes') 
                % the scores mat didn't have this, so load the results and
                % get it to add
                fprintf(1, 'adding spike and cluster counts for %s %s\n', sets{s}, algorithms{a});
                [testRes, testClu] =  readResCluTxt(fullfile(rootDir, sets{s}, [algorithms{a} '_' sets{s}]));
                numSpikes = length(testClu);
                numClusters = length(unique(testClu));
                save(fullfile(rootDir, sets{s}, [algorithms{a} '_' sets{s} '_scores.mat']), 'allScores', 'allFPs', 'allMisses', 'allMerges', 'numSpikes', 'numClusters');
            end

            
            isc = zeros(1,length(allScores));
            fsc = zeros(1,length(allScores));
            nm = zeros(1,length(allScores));
            fpr = zeros(1,length(allScores));
            mr = zeros(1,length(allScores));
            for cGT = 1:length(allScores)
                isc(cGT) = allScores{cGT}(1);
                 fsc(cGT) = allScores{cGT}(end);
                 nm(cGT) = length(allScores{cGT})-1;
                 fpr(cGT) = allFPs{cGT}(end);
                 mr(cGT) = allMisses{cGT}(end);
            end
            finalScore(s,a) = median(fsc);
            fpRate(s,a) = median(fpr);
            missRate(s,a) = median(mr);
            numMerges(s,a) = median(nm);
            initialScore(s,a) = median(isc);
            nSpikes(s,a) = numSpikes;
            nClusters(s,a) = numClusters;
        end
    end
end

f = figure; set(f, 'Position', [-1896         -80        1501         992]);
subplot(3, 3, 1);
bar(finalScore)
% legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
ylim([0 1]);
ylabel('median post-merge score')
makepretty;
            
subplot(3, 3, 2);
bar(fpRate)
legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
ylim([0 0.3]);
ylabel('median false positive')
makepretty;


subplot(3, 3, 3);
bar(missRate)
% legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
ylim([0 0.3]);
ylabel('median miss rate')
makepretty;


subplot(3, 3, 4);
bar(numMerges)
% legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
% ylim([0 1]);
ylabel('median number of merges')
makepretty;


subplot(3, 3, 5);
bar(initialScore)
% legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
ylim([0 1]);
ylabel('median initial score')
makepretty;

subplot(3,3,6);
bar(nSpikes)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
ylabel('number of spikes detected')
makepretty;

subplot(3,3,7);
bar(nClusters)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
ylabel('number of clusters/templates')
makepretty;

saveFig(f, fullfile(rootDir, 'overallSummary'));