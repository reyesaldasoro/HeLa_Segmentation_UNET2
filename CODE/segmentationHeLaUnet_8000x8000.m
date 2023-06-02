%% Clear all variables and close all figures
clear all
close all
clc


%% Read the files that have been stored in the current folder
% To be adapted depending on the computer where this is executed
if strcmp(filesep,'/')
    % Running in Mac
    %    load('/Users/ccr22/OneDrive - City, University of London/Acad/ARC_Grant/Datasets/DataARC_Datasets_2019_05_03.mat')
    cd ('/Users/ccr22/Acad/GitHub/HeLa_Segmentation_UNET2/CODE')
    %    baseDir                             = 'Metrics_2019_04_25/metrics/';
else
    %     % running in windows HP
    %     cd ('D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE')
    %     dataSaveDir = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\Results';
    %     dataSetDir =  'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\';
    %     GTDir =  'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth\';
    %     baseDirSeg              = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth_4c\';
    
    %    baseDirData             = 'D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\';
    %    dirData                 = dir(strcat(baseDirData,'*.tiff'));
    
    % running in windows Alienware
    baseDir         = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\';
    baseDirData     = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
    dirData         = dir(strcat(baseDirData,'*.tiff'));
    
    
    cd (strcat(baseDir,'CODE'))
    dataSaveDir = strcat(baseDir,'CODE\Results\');
    dataSetDir  = strcat(baseDir,'CODE\');
    %GTDir       = strcat(baseDir,'CODE\GroundTruth\');

    baseDirSeg  = strcat(baseDir,'CODE\GroundTruth_4c\');
    
    dirSeg      = dir(strcat(baseDirSeg,'*.mat'));
    GTDir       = strcat(baseDir,'CODE\GroundTruth_4c\');
    dirGT       = dir(strcat(GTDir,'*.mat'));
    GTDir_multi       = strcat(baseDir,'CODE\GroundTruth_multiNuclei\');
    dirGT_multi       = dir(strcat(GTDir_multi,'*.mat'));
end


numSlices       = numel(dirData);


%% Load U-Net definition and training
numClasses                  = 4 ;
% ----- Strategy 1 ------
% net2 has been trained with 36,000 patches from slices 101:2:180 = 40 slices, patches
% are 128x128 with 50 overlap, thus for each slice there are 30x30 = 900 patches,
% 900 x 40 = 36,000
%load Unet_36000_2022_02_02

% ----- Strategy 2 ------
% net2 has been trained with 36,000 patches from slices 1:2:300 = 150 slices, patches
% are 128x128 with 50 overlap, thus for each slice there are 30x30 = 900 patches,
% 900 x 150 = 135,000
load Unet_135000_2022_02_09

% ----- Strategy 3 ------
% In addition to the previous   135,000 patches, another 135,000 were
% generated automatically from the 8000 slices with the algorithm for a
% total of 270,000
%load Unet_270000_2022_10_17_B

% ----- Strategy 4 ------
% take only the  135,000 that were
% generated automatically from the 8000 slices with the algorithm for a
% WITHOUT the original 135,000
%load Unet_135000_ImProc_2023_01_24


%%
currentSlice        =330;% 1:numSlices 
    disp(currentSlice)
    %currentData         = imread(strcat(baseDirData,'ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    
    [rows,cols]          = size(currentData);
    % With low memory this can create errors, use the four  quadrants instead
    dataF               = imfilter(currentData,gaussF(3,3,1),'replicate');
    %segmentedData       = semanticseg(dataF,net2);   
    % Segmentation in blocks
    for cRows = 1:2048:rows
        for cCols = 1:2048:cols
            segmentedData(cRows:cRows+2048-1,cCols:cCols+2048-1) = semanticseg(dataF(cRows:cRows+2048-1,cCols:cCols+2048-1),net2);
        end
    end

    
    % %%%%%% Intermediate display of results %%%%%%%
    % segmentationAndData                   = labeloverlay(dataF, segmentedData);
    % figure; imagesc(segmentationAndData)
    % Convert from semantic to numeric to calculate jaccard and accuracy
    % Result has the following classes:
    % 1 - Nuclear Envelope, 2 - Nucleus, 3-Cell, 4 - Background
    result               = zeros(rows,cols);
    for counterClass=1:numClasses
        result = result +(counterClass*(segmentedData==strcat('T',num2str(counterClass))));
    end

    
    % postProcess
    new_result                      = postProcessHela(result);

%%
figure
currentdataF     = imfilter(currentData,gaussF(3,3,1),'replicate');
resultRGB        = zeros(rows,cols,3);

% cyan background / purple nucleus
% resultRGB(:,:,1) = currentdataF;
% resultRGB(:,:,2) = resultRGB(:,:,1).*(new_result~=2)+0.5*resultRGB(:,:,1).*(new_result==2);
% resultRGB(:,:,3) = resultRGB(:,:,1);
% resultRGB(:,:,1) = resultRGB(:,:,1).*(new_result~=3)+0.8*resultRGB(:,:,1).*(new_result==3);
%resultRGB(:,:,2) = resultRGB(:,:,1).*(new_result~=2)+0.3*resultRGB(:,:,1).*(new_result==2);


% orange cell / gray background / green nucleus / blue NE
nuclearEnvelope = imdilate(new_result==1,ones(9));

resultRGB(:,:,1) = currentdataF+50*uint8(new_result==3).*uint8(1-nuclearEnvelope);
resultRGB(:,:,2) = currentdataF+50*uint8(new_result==2).*uint8(1-nuclearEnvelope);
resultRGB(:,:,3) = currentdataF+50*uint8(nuclearEnvelope);

imagesc(resultRGB/255)
%%

h0 = gcf;
h1 = gca;
h1.Position=[0 0 1 1];
h0.Position= [180    270    1000    450];
axis([1 7000 4000 7400])
axis off
%%
%filename = 'Figures/Result_8000_330_Unet_270000_2022_10_19.png';
%filename = 'Figures/Result_8000_330_Unet_135000_2022_10_19.png';
%filename = 'Figures/Result_8000_330_Unet_36000_2022_10_19.png';
filename = 'Figures/Result_8000_330_Unet_135000ImProc_2023_01_25.png';

print('-dpng','-r400',filename)

%% Figure to illustrate post-processing
h1=figure;
h1.Position =[  65.8000  353.0000  754.4000  300.0000];

h241=subplot(141);
imagesc(imfilter(currentData,gaussF(3,3,1)))
axis([1600 3200 3700 5600 ])
h242=subplot(142);
imagesc(result)
axis([1600 3200 3700 5600 ])
h243=subplot(143);
imagesc(new_result)
axis([1600 3200 3700 5600 ])
h244=subplot(144);
imagesc(result==new_result)
axis([1600 3200 3700 5600 ])

colormap gray
fSize   = 14;

h241.Title.FontSize=fSize; h241.Title.String='(a)';
h242.Title.FontSize=fSize; h242.Title.String='(b)';
h243.Title.FontSize=fSize; h243.Title.String='(c)';
h244.Title.FontSize=fSize; h244.Title.String='(d)';
%
hW      = 0.90;
hH      = 0.235;
hBase   = 0.02;
hBase2  = 0.02;
h241.Position = [0.01 hBase2 hH hW];h241.XTick=[];h241.YTick=[];
h242.Position = [0.26 hBase2 hH hW];h242.XTick=[];h242.YTick=[];
h243.Position = [0.51 hBase2 hH hW];h243.XTick=[];h243.YTick=[];
h244.Position = [0.76 hBase2 hH hW];h244.XTick=[];h244.YTick=[];
%
rr1 = 3100;
rr2 = 4200;
cc1 =  800;
cc2 = 1800;
h241.XLim= [cc1        cc2]; h241.YLim= [rr1        rr2];
h242.XLim= [cc1        cc2]; h242.YLim= [rr1        rr2];
h243.XLim= [cc1        cc2]; h243.YLim= [rr1        rr2];
h244.XLim= [cc1        cc2]; h244.YLim= [rr1        rr2];

%%
filename = 'Figures/PostProcessing_Unet_270000_2022_10_19.png';
print('-dpng','-r400',filename)
