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
% net2 has been trained with 36,000 patches from slices 101:2:180 = 40 slices, patches
% are 128x128 with 50 overlap, thus for each slice there are 30x30 patches,
% 900 x 40 = 36,000
load Unet_36000_2022_02_02


%% Run segmentation in all slices
% Once the U-Net has been trained, segmentation is performed here:
accuracy(numSlices)     =0;
accuracy1(numSlices)    =0;
accuracy2(numSlices)    =0;
accuracy3(numSlices)    =0;
jaccard1(numSlices)     =0;
jaccard2(numSlices)     =0;
jaccard3(numSlices)     =0;

%%
for  currentSlice        =330% 1:numSlices 
    disp(currentSlice)
    %currentData         = imread(strcat(baseDirData,'ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    
    [rows,cols]          = size(currentData);
    %currentGT           = load (strcat(GTDir,dirGT(currentSlice).name));
    %groundTruth         = currentGT.groundTruth;
    
    %currentGT_multi           = load (strcat(GTDir_multi,dirGT_multi(currentSlice).name));
    %groundTruth_multi         = currentGT_multi.groundTruth;
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

%     % Calculate Metrics,
%     % Absolute accuracy for all classes
%     accuracy(currentSlice)         = sum(sum(result==groundTruth_multi))/rows/cols;
%     
%     % Accuracy, Jaccard for single nucleus
%     TP                              = (groundTruth==2).*(result==2);
%     TN                              = (groundTruth~=2).*(result~=2);
%     FP                              = (groundTruth~=2).*(result==2);
%     FN                              = (groundTruth==2).*(result~=2);
%     accuracy1(currentSlice)         = (sum(TP(:))+sum(TN(:)))/rows/cols;
%     jaccard1(currentSlice)          = (sum(TP(:)))/(sum(TP(:))+sum(FN(:))+sum(FP(:)));
%     
%     
%     % Accuracy, Jaccard for the multi Nuclei
%     TP                              = (groundTruth_multi==2).*(result==2);
%     TN                              = (groundTruth_multi~=2).*(result~=2);
%     FP                              = (groundTruth_multi~=2).*(result==2);
%     FN                              = (groundTruth_multi==2).*(result~=2);
%     accuracy2(currentSlice)         = (sum(TP(:))+sum(TN(:)))/rows/cols;
%     jaccard2(currentSlice)          = (sum(TP(:)))/(sum(TP(:))+sum(FN(:))+sum(FP(:)));
    
    % postProcess
    new_result                      = postProcessHela(result);
%     TP2                              = (groundTruth_multi==2).*(new_result==2);
%     TN2                              = (groundTruth_multi~=2).*(new_result~=2);
%     FP2                              = (groundTruth_multi~=2).*(new_result==2);
%     FN2                              = (groundTruth_multi==2).*(new_result~=2);
%     accuracy3(currentSlice)         = (sum(TP2(:))+sum(TN2(:)))/rows/cols;
%     jaccard3(currentSlice)          = (sum(TP2(:)))/(sum(TP2(:))+sum(FN2(:))+sum(FP2(:)));    
%     %jaccard(currentSlice)          = sum(sum( (groundTruth==2).*(result==2) )) / sum(sum ( ((groundTruth==2)|(result==2)) ));

    % accuracy(currentSlice)         = sum(sum(new_result==groundTruth_multi))/rows/cols;   
     
     
    %save(strcat(dataSaveDir,filesep,'accuracy','_',num2str(timeSaved(1)),'_',num2str(timeSaved(2)),'_',num2str(timeSaved(3)),'128x128_raw_LPF'),'accuracy','jaccard')   
end
%timeSaved= datevec(date);
%saveName    =strcat(dataSaveDir,'accuracy','_',num2str(timeSaved(1)),'_',num2str(timeSaved(2)),'_',num2str(timeSaved(3)),'_128x128');

%save(saveName,'acc*','jac*')    
 %%
% figure
% subplot(221)
% imagesc(repmat(dataF,[1 1 3]))
% subplot(222)
% imagesc(groundTruth_multi)
% subplot(223) 
% imagesc(result)
% subplot(224)
% imagesc(new_result)
% colormap jet
%%
figure
currentdataF     = imfilter(currentData,gaussF(3,3,1),'replicate');
resultRGB        = zeros(rows,cols,3);
resultRGB(:,:,1) = currentdataF;
resultRGB(:,:,2) = resultRGB(:,:,1).*(new_result~=2)+0.5*resultRGB(:,:,1).*(new_result==2);
resultRGB(:,:,3) = resultRGB(:,:,1);
resultRGB(:,:,1) = resultRGB(:,:,1).*(new_result~=4)-0.8*resultRGB(:,:,1).*(new_result==4);

imagesc(resultRGB/255)
