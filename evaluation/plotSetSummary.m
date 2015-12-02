function plotSetSummary(rootDir, setName)

algorithms = {'phy', 'spykingCircus', 'globalSuper', 'kiloSort'};

% rootDir = 'V:\nick\GroundTruth\';


for a = 1:length(algorithms)
    entryFile = fullfile(rootDir, setName, [algorithms{a} '_' setName '_scores.mat']);
    if exist(entryFile)
        load(entryFile)
        
        if a==1
        
            initialScore = zeros(length(algorithms),length(allScores));
            finalScore = zeros(length(algorithms),length(allScores));
            numMerges = zeros(length(algorithms),length(allScores));
            fpRate = zeros(length(algorithms),length(allScores));
            missRate = zeros(length(algorithms),length(allScores));
        end
        
        for cGT = 1:length(allScores)
            initialScore(a, cGT) = allScores{cGT}(1);
            finalScore(a, cGT) = allScores{cGT}(end);
            numMerges(a, cGT) = length(allScores{cGT})-1;
            fpRate(a, cGT) = allFPs{cGT}(end);
            missRate(a, cGT) = allMisses{cGT}(end);
        end
    end
end

f = figure; set(f, 'Position', [-1896         -80        1501         992]);
subplot(2, 3, 1);
bar(finalScore')
% legend(algorithms)
set(gca, 'XTick', 1:size(finalScore,2), 'XTickLabel', 1+(1:size(finalScore,2)));
ylim([0 1]);
ylabel('post-merge score')
xlabel('GT cluster number')
makepretty;
            
subplot(2, 3, 2);
bar(fpRate')
legend(algorithms)
set(gca, 'XTick', 1:size(finalScore,2), 'XTickLabel', 1+(1:size(finalScore,2)));
ylim([0 0.3]);
ylabel('false positive')
makepretty;


subplot(2, 3, 3);
bar(missRate')
% legend(algorithms)
set(gca, 'XTick', 1:size(finalScore,2), 'XTickLabel', 1+(1:size(finalScore,2)));
ylim([0 0.3]);
ylabel('miss rate')
makepretty;


subplot(2, 3, 4);
bar(numMerges')
% legend(algorithms)
set(gca, 'XTick', 1:size(finalScore,2), 'XTickLabel', 1+(1:size(finalScore,2)));
% ylim([0 1]);
ylabel('number of merges')
makepretty;


subplot(2, 3, 5);
bar(initialScore')
% legend(algorithms)
set(gca, 'XTick', 1:size(finalScore,2), 'XTickLabel', 1+(1:size(finalScore,2)));
ylim([0 1]);
ylabel('initial score')
makepretty;


saveFig(f, fullfile(rootDir, [setName '_summary']));