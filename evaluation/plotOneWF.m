

function plotOneWF(waveform, chanCoords, params)
% waveform is nChans x nTimePnts
% chanCoords is nChans x 2 [second dim is x, y]

p.LineWidth = 2.0;
p.Color = [0 0 0];
p.yMult = [];
p.xOffset = 0;
p.ColorGradient = false; 
p.ColorThresh = false;
colorFactor = 8/10e4;       

if ~isempty(params)
    params = mergeStructs(params, p); % first one overrides second

else
    params = p;
end
% params
waveform = double(waveform);
waveform = bsxfun(@minus, waveform, mean(waveform, 2));

% first make some kind of guess about how to scale things properly. This
% will work fine if channels are evenly spaced.
allY = unique(chanCoords(:,2));
allX = unique(chanCoords(:,1));

if length(allX)>1
    xScale = mean(diff(allX));
else
    xScale = 1;
end

if length(allY)>1
    yScale = mean(diff(allY)); 
else
    yScale = 1;
end

nTimePnts = size(waveform,2);
xCoords = (1:nTimePnts)/nTimePnts*xScale;

wfAmps = max(waveform,[],2)-min(waveform,[],2);
maxYamp = max(wfAmps);
if isempty(params.yMult)
    params.yMult = yScale/maxYamp*3;
end

if params.ColorThresh
    bckgLevel = median(wfAmps);
    halfHeight = (max(wfAmps)-bckgLevel)/8+bckgLevel;    
else
    halfHeight = -1;
end


for c = 1:size(chanCoords,1)        
    if wfAmps(c)>halfHeight
        
        if params.ColorGradient
            
            thisColor = params.Color*min([wfAmps(c)/colorFactor, 1]);
        else
            thisColor = params.Color;
        end
        
        plot(xCoords+chanCoords(c,1)+params.xOffset, params.yMult.*waveform(c,:)+chanCoords(c,2), 'Color', thisColor, 'LineWidth', params.LineWidth); 
        hold on;
    end
end