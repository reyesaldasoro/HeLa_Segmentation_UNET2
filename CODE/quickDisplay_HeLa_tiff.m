
    % running in windows Alienware
    baseDir         = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\';
    baseDirData     = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
    dirData         = dir(strcat(baseDirData,'*.tiff'));
%%
currentSlice = 20;
currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
dataF               = imfilter(currentData,gaussF(3,3,1),'replicate');
imagesc(dataF)

axis([1 3500 3000 6000 ])

% filename =strcat('Hela_slice_',num2str(currentSlice),'_StrangeCells_A_B.png');