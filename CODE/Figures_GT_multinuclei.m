

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
%% load results multinuclei Unet This is the earlier training U-Net
%load('Results_Unet_Hela_multinuclei_2021_08_26.mat')
%clear j_* ja* ac* a_*
% load('Results_Seg_Unet_Hela_multinuclei_2021_09_16')
%% Recent U-Net training multinuclei
%load('Results_Seg_Unet_Hela_multinuclei_2022_03_03_36000')
load('Results_Seg_Unet_Hela_multinuclei_2022_03_03_135000')

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
% resultAll (rows,cols,numSlices) = 0;
% accuracy1(numSlices)            = 0;
% jaccard1(numSlices)             = 0;
% accuracy2(numSlices)            = 0;
% jaccard2(numSlices)             = 0;
% accuracy3(numSlices)            = 0;
% jaccard3(numSlices)             = 0;

structEl                        = strel('disk',30);
structEl2                        = strel('disk',50);
structEl3                        = strel('disk',5);
%load('UNet_128x128_Hela.mat')
centreCell                      = zeros(rows,cols);
centreCell(450:1400,350:1400)   = 1;
for slicesT = 151 %[48 71 82 170 215 251]  %:numSlices 
    currentSlice        = slicesToSegment(slicesT); %260% 1:300
    disp(currentSlice)
            currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
            %currentSeg          = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329_manual\ROI_1656-6756-329_z0',num2str(currentSlice),'.tif'));
            
            currentSeg          = load(strcat(baseDirSeg,dirSeg(currentSlice).name));
            groundTruth         = currentSeg.groundTruth;
            currentSeg2          = load(strcat(baseDirSeg2,dirSeg(currentSlice).name));
            groundTruth2         = currentSeg2.groundTruth;
            
            
            GT_RGB(:,:,1) = imfilter(currentData,fspecial('Gaussian',3,1),'replicate');
            GT_RGB(:,:,2) = GT_RGB(:,:,1)+60*uint8(centreCell.*(groundTruth2==2));
            GT_RGB(:,:,3) = GT_RGB(:,:,1)+30*uint8(groundTruth2==2);
            GT_RGB(GT_RGB>255)=255;
            GT_RGB(GT_RGB<0)=0;
            
            HI_RGB(:,:,1) = imfilter(currentData,fspecial('Gaussian',3,1),'replicate');
            HI_RGB(:,:,2) = HI_RGB(:,:,1)+60*uint8(Hela_nuclei(:,:,currentSlice));
            HI_RGB(:,:,3) = HI_RGB(:,:,1);
            HI_RGB(HI_RGB>255)=255;
            HI_RGB(HI_RGB<0)=0;
            
            AI_RGB(:,:,1) = imfilter(currentData,fspecial('Gaussian',3,1),'replicate');
            AI_RGB(:,:,2) = AI_RGB(:,:,1)+60*uint8(result_Unet(:,:,currentSlice)==2);
            AI_RGB(:,:,3) = AI_RGB(:,:,1);
            AI_RGB(AI_RGB>255)=255;
            AI_RGB(AI_RGB<0)=0;
            
            AI_RGB2(:,:,1) = imfilter(currentData,fspecial('Gaussian',3,1),'replicate');
            AI_RGB2(:,:,2) = AI_RGB2(:,:,1)+60*uint8(result_Unet_filt(:,:,currentSlice)==2);
            AI_RGB2(:,:,3) = AI_RGB2(:,:,1);
            AI_RGB2(AI_RGB2>255)=255;
            AI_RGB2(AI_RGB2<0)=0;
            %imagesc((groundTruth==2)+(groundTruth2==2))
  h1 =figure(2);
  h241=subplot(2,4,1);
            imagesc(GT_RGB)
  h242=subplot(2,4,2);
            imagesc(HI_RGB)
  h243=subplot(2,4,3);
            imagesc(AI_RGB)
  h244=subplot(2,4,4);
            imagesc(AI_RGB2)
  h245=subplot(2,4,5);
             imagesc((groundTruth2==2)+2*(centreCell.*(groundTruth2==2)))
  h246=subplot(2,4,6);
             imagesc(-Hela_nuclei(:,:,currentSlice)+2*(centreCell.*(groundTruth2==2)))
  h247=subplot(2,4,7);
             imagesc(-double(result_Unet(:,:,currentSlice)==2)+2*(groundTruth2==2))
  h248=subplot(2,4,8);
             imagesc(-double(result_Unet_filt(:,:,currentSlice)==2)+2*(groundTruth2==2))
                  colormap gray
            %             figure(1)
%             imagesc(GT_RGB)
%             figure(2)
%             imagesc(HI_RGB)
%             figure(3)
%             imagesc(AI_RGB)
%             figure(4)
%             imagesc(AI_RGB2)
%             figure(5)
%              imagesc(-Hela_nuclei(:,:,currentSlice)+2*(centreCell.*(groundTruth2==2)))
%              colormap gray
%             figure(6)
%              imagesc(-double(result_Unet(:,:,currentSlice)==2)+2*(groundTruth2==2))
%              colormap gray           
%              figure(7)
%              imagesc(-double(result_Unet_filt(:,:,currentSlice))+2*(groundTruth2==2))
%              colormap gray
%              figure(8)
%              imagesc((groundTruth2==2)+2*(centreCell.*(groundTruth2==2)))
%                   colormap gray
end
%
hW      = 0.42;
hH      = 0.235;
hBase   = 0.02;
hBase2  = 0.52;
fSize   = 14;
%
h1.Position =[  65.8000  353.0000  754.4000  420.0000];

h241.Position = [0.01 hBase2 hH hW];h241.XTick=[];h241.YTick=[];
h242.Position = [0.26 hBase2 hH hW];h242.XTick=[];h242.YTick=[];
h243.Position = [0.51 hBase2 hH hW];h243.XTick=[];h243.YTick=[];
h244.Position = [0.76 hBase2 hH hW];h244.XTick=[];h244.YTick=[];
h245.Position = [0.01 hBase hH hW];h245.XTick=[];h245.YTick=[];
h246.Position = [0.26 hBase hH hW];h246.XTick=[];h246.YTick=[];
h247.Position = [0.51 hBase hH hW];h247.XTick=[];h247.YTick=[];
h248.Position = [0.76 hBase hH hW];h248.XTick=[];h248.YTick=[];

h241.Title.FontSize=fSize; h241.Title.String='(a)';
h242.Title.FontSize=fSize; h242.Title.String='(b)';
h243.Title.FontSize=fSize; h243.Title.String='(c)';
h244.Title.FontSize=fSize; h244.Title.String='(d)';
h245.Title.FontSize=fSize; h245.Title.String='(e)';
h246.Title.FontSize=fSize; h246.Title.String='(f)';
h247.Title.FontSize=fSize; h247.Title.String='(g)';
h248.Title.FontSize=fSize; h248.Title.String='(h)';

filename = strcat('Hela_segmentation_multinuclei_accuracy_2022_03_03_135000_',num2str(slicesT),'.png');
