    baseDirData     = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
    dirData         = dir(strcat(baseDirData,'*.tiff'));
%%

currentSlice        =330% 1:numSlices 
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    
    [rows,cols]          = size(currentData);
    dataF               = imfilter(currentData,gaussF(3,3,1),'replicate');
    
    imagesc(dataF(3701:5990,101:3500))

%%

%dataF2                              = dataF(3701:5700,1501:3500);
dataF2                              = dataF(2501:4500,3801:5800);
Hela_background   = segmentBackgroundHelaEM(dataF2);
  Hela_nuclei       = segmentNucleiHelaEM(   dataF2,[],[],Hela_background);
  figure
imagesc(dataF2 +80*uint8(Hela_background)+50*uint8(Hela_nuclei))
   