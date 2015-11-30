

function [allScores, allFPs, allMisses, allMerges] = compareClustering(cluGT, resGT, cluTest, resTest, datFilename, entryDir)
% function compareClustering(cluGT, resGT, cluTest, resTest[, datFilename])
% - clu and res variables are length nSpikes, for ground truth (GT) and for
% the clustering to be evaluated (Test). 

if nargin<5
    datFilename = [];
    entryDir=[];
end
if nargin<6
    entryDir = [];
end

if ~isempty(entryDir)
    fid = fopen([entryDir 'results.txt'], 'w');
else
    fid = [];
end

try
    GTcluIDs = unique(cluGT);
    testCluIDs = unique(cluTest);


    for cGT = 1:length(GTcluIDs)
        mfprintf([1 fid],'ground truth cluster ID = %d (%d spikes)\n', GTcluIDs(cGT), sum(cluGT==GTcluIDs(cGT)));

        rGT = int32(resGT(cluGT==GTcluIDs(cGT)));

        % find the initial best match
        mergeIDs = [];
        scores = [];
        falsePos = [];
        missRate = [];
        misses = zeros(1,length(testCluIDs)); fps = zeros(1,length(testCluIDs));

        for cTest = 1:length(testCluIDs)
            rTest = int32(resTest(cluTest==testCluIDs(cTest)));

            [miss, fp] = compareSpikeTimes(rTest, rGT);

            if miss<0; miss=0; end; if fp<0; fp=0; end; % rectify to help a little bit with the errors of this algorithm

            misses(cTest) = miss;
            fps(cTest) = fp;

        end

        sc = 1-(fps+misses);
        best = find(sc==max(sc),1);
        mergeIDs(end+1) = testCluIDs(best);
        scores(end+1) = sc(best);
        falsePos(end+1) = fps(best);
        missRate(end+1) = misses(best);

        mfprintf([1 fid], '  found initial best %d: score %.2f (%d spikes, %.2f FP, %.2f miss)\n', mergeIDs(1), scores(1), sum(cluTest==mergeIDs(1)), fps(best), misses(best));

        tempCluTest = cluTest;

        while length(scores)==1 || ( scores(end)>(scores(end-1)+0.01) && scores(end)<=0.99 )
            % find the best match
            tempTestCluIDs = unique(tempCluTest);
            misses = nan(1,length(tempTestCluIDs)); fps = nan(1,length(tempTestCluIDs));
            for cTest = 1:length(tempTestCluIDs)     
                if tempTestCluIDs(cTest)~=mergeIDs(1)
                    rTest = int32(resTest(tempCluTest==tempTestCluIDs(cTest)|tempCluTest==mergeIDs(1)));

                    [miss, fp] = compareSpikeTimes(rTest, rGT);

                    if miss<0; miss=0; end; if fp<0; fp=0; end; % rectify to help a little bit with the errors of this algorithm

                    misses(cTest) = miss;
                    fps(cTest) = fp;
                end
            end

            sc = 1-(fps+misses);
            best = find(sc==max(sc),1);
            mergeIDs(end+1) = tempTestCluIDs(best);
            scores(end+1) = sc(best);
            falsePos(end+1) = fps(best);
            missRate(end+1) = misses(best);

            mfprintf([1 fid], '    best merge with %d: score %.2f (%d/%d new/total spikes, %.2f FP, %.2f miss)\n', mergeIDs(end), scores(end), sum(tempCluTest==mergeIDs(end)), sum(tempCluTest==mergeIDs(1)|tempCluTest==mergeIDs(end)), fps(best), misses(best));

            % now merge
            tempCluTest(tempCluTest==mergeIDs(end)) = mergeIDs(1);

        end

        if length(scores)==1 || scores(end)>(scores(end-1)+0.01)
            % the last merge did help, so include it
            allMerges{cGT} = mergeIDs(1:end);
            allScores{cGT} = scores(1:end);
            allFPs{cGT} = falsePos(1:end);
            allMisses{cGT} = missRate(1:end);
        else
            % the last merge actually didn't help (or didn't help enough), so
            % exclude it
            allMerges{cGT} = mergeIDs(1:end-1);
            allScores{cGT} = scores(1:end-1);
            allFPs{cGT} = falsePos(1:end-1);
            allMisses{cGT} = missRate(1:end-1);
        end

    end

    initScore = zeros(1, length(GTcluIDs));
    finalScore = zeros(1, length(GTcluIDs));
    numMerges = zeros(1, length(GTcluIDs));
    mfprintf([1 fid], '\n\n--Results Summary--\n')
    for cGT = 1:length(GTcluIDs)

         mfprintf([1 fid],'ground truth cluster ID = %d (%d spikes)\n', GTcluIDs(cGT), sum(cluGT==GTcluIDs(cGT)));
         mfprintf([1 fid],'  initial score: %.2f (%.2f FP, %.2f miss)\n', allScores{cGT}(1), allFPs{cGT}(1), allMisses{cGT}(1));
         mfprintf([1 fid],'  best score: %.2f  (%.2f FP, %.2f miss, after %d merges)\n', allScores{cGT}(end), allFPs{cGT}(end), allMisses{cGT}(end), length(allScores{cGT})-1);

         initScore(cGT) = allScores{cGT}(1);
         finalScore(cGT) = allScores{cGT}(end);
         numMerges(cGT) = length(allScores{cGT})-1;
    end

    mfprintf([1 fid], '---\n');
    mfprintf([1 fid], 'average initial score: %.2f; average best score: %.2f\n', mean(initScore), mean(finalScore));
    mfprintf([1 fid], 'total merges required: %d\n', sum(numMerges));

    if ~isempty(datFilename)

        nChansInRawFile = 129;
        nChansToUse = 128;
        tBefore = 10; tAfter = 30; nSpikesForAvg = 200;
        nT = tBefore+tAfter+1;

        f = figure;
        load('forPRBimecToWhisper.mat'); connected = logical(connected);


        for cGT = 1:length(GTcluIDs)

            gtTimes = resGT(cluGT==GTcluIDs(cGT));
            testTimes = resTest(cluTest==allMerges{cGT}(1));
            nS = min(nSpikesForAvg, length(gtTimes));
            [meanWF, ~] = readWaveformsFromDat(datFilename, nChansInRawFile, gtTimes, [-tBefore tAfter], nS);
            gtWF = meanWF(chanMap,:);

            nS = min(nSpikesForAvg, length(testTimes));
            [meanWF, ~] = readWaveformsFromDat(datFilename, nChansInRawFile, testTimes, [-tBefore tAfter], nS);
            testWF = meanWF(chanMap,:);


            subplot(1, length(GTcluIDs), cGT);
            params.Color = [0 0 1]; params.LineWidth = 2.0;
            plotOneWF(gtWF(connected,:), [xcoords(connected) ycoords(connected)], params);
            hold on;
            params.Color = [1 0 0]; params.LineWidth = 1.0;
            plotOneWF(testWF(connected,:), [xcoords(connected) ycoords(connected)], params);
            title(sprintf('%.2f', allScores{cGT}(end)));
        end

    end
catch me
    fclose(fid)
    rethrow(me)
end

if ~isempty(fid)    
    fclose(fid)
end