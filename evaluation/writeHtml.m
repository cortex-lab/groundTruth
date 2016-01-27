

 fid = fopen('V:\www\phy.cortexlab.net\data\sortingComparison\index.html', 'w');
 
 fwrite(fid, '<html><body>');
 
 fwrite(fid, '<p><a href="/data/sortingComparison/datasets">Datasets</a></p>');
 fwrite(fid, '<p><a href="/data/sortingComparison/results">Raw results</a></p>');
 
 fwrite(fid, '<p><a href="https://github.com/cortex-lab/groundTruth">Ground truth creation and evaluation code (GitHub)</a></p>');
 fwrite(fid, '<p><a href="/data/sortingComparison/algorithmDescriptions.html">Descriptions of tested algorithms</a></p>');
 
 fwrite(fid, '<h1>Sorting comparison results</h1>');
 
 fwrite(fid, ['<p>Last updated ' datestr(now) '</p>']);
 
 fwrite(fid, '<img width="100%" src="/data/sortingComparison/results/overallSummary.jpg">')
 
 for setNum = 1:6
     fwrite(fid, sprintf('<h2>Set %d results </h2>', setNum));     
     fwrite(fid, sprintf('<img width="100%%" src="/data/sortingComparison/results/set%d_summary.jpg">',setNum));
 end
 
 fwrite(fid, '</body></html>');