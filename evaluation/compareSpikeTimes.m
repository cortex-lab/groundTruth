

function [miss, fp] = compareSpikeTimes(rComp, rGT)
% rComp and rGT are vectors of spike times in samples. Recommend int32 type
% for memory reasons. 

useAlgorithm = 2;

jitter = 30; % number of samples separation less than which two spikes are considered "the same"

if length(rComp)>2*length(rGT)
    % skip this for performance reasons. If it truly does contain all the
    % GT spikes, then this is poor performance anyway. 
    miss = 1; fp = 1;
    return
end

if length(rComp)<2
    % the bsxfun below will not use the correct dimensions in this case.
    % You don't want it anyway. 
    miss = 1; fp = 1;
    return;
end


switch useAlgorithm
    case 1
        % algorithm 1: repmat/bsxfun

        rComp = rComp(:); % Mx1
        rGT = rGT(:)'; % 1xN

        % minDiffs has one entry for each GT spike, the distance in samples from
        % that spike to the nearest comparison spike. 
        minDiffs = min(abs(bsxfun(@minus, repmat(rComp, 1, length(rGT)), rGT))); 

        miss = sum(minDiffs>jitter)/length(rGT); % missed these spikes, as a proportion of the total true spikes



        % now minDiffs has one entry for each Comparison spike; distance to nearest
        % GT
        minDiffs = min(abs(bsxfun(@minus, repmat(rGT', 1, length(rComp)), rComp'))); 

        fp = sum(minDiffs>jitter)/length(rComp); % number of comparison spikes not near a GT spike, as a proportion of the number of guesses


    case 2
        % algorithm 2: based on Kenneth's CCG

        HalfBins = 0;
        BinSize = jitter;
        %SampleRate = 1;
        
        %t = 1000*(-HalfBins:HalfBins)*BinSize/SampleRate;
        
        Res = [rComp(:);rGT(:)];
        Clu = [zeros(length(rComp),1);ones(length(rGT),1)]+1;
        [Res ind] = sort(Res);
        Clu = Clu(ind);
        Counts = CCGHeart(double(Res), uint32(Clu), BinSize, uint32(HalfBins));
        numMatch = Counts(2);
        %[ccg, t] = CCG([rComp(:);rGT(:)], [zeros(length(rComp),1);ones(length(rGT),1)], jitter, 0, 1, [], [], []);
        
        miss = double(length(rGT)-numMatch)/double(length(rGT)); % missed these spikes, as a proportion of the total true spikes
        fp = double(length(rComp)-numMatch)/double(length(rComp)); % number of comparison spikes not near a GT spike, as a proportion of the number of guesses
        
    case 3
        
        
        rComp = sort(rComp);
        rGT = sort(rGT);
        
        compHits = false(size(rComp));
        gtHits = false(size(rGT));
        
        compInd = 1;
        cutSpike = round(length(rGT)/10); % a tenth of the way through, will decide whether to continue
        
        for gtInd = 1:length(rGT)
            
            while compInd<=length(rComp) && rComp(compInd)< (rGT(gtInd)+jitter)
                
                if rComp(compInd)> (rGT(gtInd)-jitter)
                    compHits(compInd) = true;
                    gtHits(gtInd) = true;
                    compInd = compInd+1;
                    break;
                else
                    compInd = compInd+1;
                end
                
            end
            
            if gtInd==cutSpike
                if sum(gtHits)<length(rGT)/100
                    break
                end
            end
            
        end
        
        miss = sum(double(~gtHits))/length(rGT);
        fp = sum(double(~compHits))/length(rComp);
end