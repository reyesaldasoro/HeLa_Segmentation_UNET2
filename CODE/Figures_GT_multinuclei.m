

clear variables
close all

  %% Read the files that have been stored in the current folder
if strcmp(filesep,'/')
    % Running in Mac
    %    load('/Users/ccr22/OneDrive - City, University of London/Acad/ARC_Grant/Datasets/DataARC_Datasets_2019_05_03.mat')
    cd ('/Users/ccr22/Acad/GitHub/HeLa_Segmentation_UNET2/CODE')
    %    baseDir                             = 'Metrics_2019_04_25/metrics/';
else
    % running in windows 
    try
        % old HP
        cd ('D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE')
        dataSaveDir = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\Results';
        dataSetDir  = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\';
        GTDir       = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth\';
        baseDirSeg  = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth_4c\';
        baseDirData = 'D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\';
    catch
        %New Alienware
        baseDir = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE';
        baseDirSeg  = strcat(baseDir,filesep,'GroundTruth_4c\');
        cd (baseDir);
        dataSaveDir = strcat(baseDir,filesep,'Results',filesep);
        dataSetDir  = strcat(baseDir,filesep);
        %GTDir       = strcat(baseDir,filesep,'GroundTruth\');
        baseDirSeg2 = strcat(baseDir,filesep,'GroundTruth_multiNuclei\');
        baseDirData = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329\';
       
    end
end


%% load results algorithm
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Code\Results_ROI_1656_6756_329_2021_03_09.mat')
%% load results multinuclei Unet
%load('Results_Unet_Hela_multinuclei_2021_08_26.mat')
%clear j_* ja* ac* a_*
load('Results_Seg_Unet_Hela_multinuclei_2021_09_15')

%%
numClasses                  = 4 ;
  rows = 2000;
  cols = 2000;
  


dirSeg                  = dir(strcat(baseDirSeg,'*.mat'));
dirSeg2                  = dir(strcat(baseDirSeg2,'*.mat'));
dirData                 = dir(strcat(baseDirData,'*.tiff'));


%%  2021/08/26 saved results in  Results_Unet_Hela_multinuclei
%slicesToSegment = [170 220 260];
numSlices                       = numel(dirSeg);
slicesToSegment                 = (1:numSlices);
resultAll (rows,cols,numSlices) = 0;
accuracy1(numSlices)            = 0;
jaccard1(numSlices)             = 0;
accuracy2(numSlices)            = 0;
jaccard2(numSlices)             = 0;
accuracy3(numSlices)            = 0;
jaccard3(numSlices)             = 0;

structEl                        = strel('disk',30);
structEl2                        = strel('disk',50);
structEl3                        = strel('disk',5);
%load('UNet_128x128_Hela.mat')

for slicesT = 41%[82 170 215 251]  %:numSlices 
    currentSlice        = slicesToSegment(slicesT); %260% 1:300
    disp(currentSlice)
            currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
            %currentSeg          = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329_manual\ROI_1656-6756-329_z0',num2str(currentSlice),'.tif'));
            
            currentSeg          = load(strcat(baseDirSeg,dirSeg(currentSlice).name));
            groundTruth         = currentSeg.groundTruth;
            currentSeg2          = load(strcat(baseDirSeg2,dirSeg(currentSlice).name));
            groundTruth2         = currentSeg2.groundTruth;
            
            
            GT_RGB(:,:,1) = imfilter(currentData,fspecial('Gaussian',3,1),'replicate');
            GT_RGB(:,:,2) = GT_RGB(:,:,1)+60*uint8(groundTruth2==2);
            GT_RGB(:,:,3) = GT_RGB(:,:,1)+30*uint8(groundTruth2==2);
            GT_RGB(GT_RGB>255)=255;
            GT_RGB(GT_RGB<0)=0;
            %imagesc((groundTruth==2)+(groundTruth2==2))
            figure(1)
            imagesc(GT_RGB(:,:,:))
            figure(2)
            imagesc((groundTruth==2)+(groundTruth2==2))
            figure(3)
             imagesc(-Hela_nuclei(:,:,currentSlice)+2*(groundTruth2==2))
            figure(4)
             imagesc(-double(resultAll(:,:,currentSlice))+2*(groundTruth2==2))
            
end



