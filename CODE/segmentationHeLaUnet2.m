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
    baseDirData     = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\';
    dirData                 = dir(strcat(baseDirData,'*.tiff'));
    
    
    cd (strcat(baseDir,'CODE'))
    dataSaveDir = strcat(baseDir,'CODE\Results\');
    dataSetDir  = strcat(baseDir,'CODE\');
    %GTDir       = strcat(baseDir,'CODE\GroundTruth\');
    GTDir       = strcat(baseDir,'CODE\GroundTruth_multiNuclei\');
    baseDirSeg  = strcat(baseDir,'CODE\GroundTruth_4c\');
    
    dir_8000    = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
    dirSeg      = dir(strcat(baseDirSeg,'*.mat'));
    dirGT       = dir(strcat(GTDir,'*.mat'));
end


numSlices       = numel(dirGT);
%% Training data and labels
% location of the training data data and labels are stored as pairs of textures arranged in Horizontal,
% Vertical and Diagonal pairs of class 1-2, 1-3, 1-4 ... 2-1, 2-3,...
imageDir                    = fullfile(dataSetDir,strcat('trainingImages_4c_128',filesep));
labelDir                    = fullfile(dataSetDir,strcat('trainingLabels_4c_128',filesep));
sizeTrainingPatch           = 128;

%imageDir                   = fullfile(dataSetDir,strcat('trainingImages_4c',filesep));
%labelDir                   = fullfile(dataSetDir,strcat('trainingLabels_4c',filesep));
%sizeTrainingPatch          = 64;


% imageDir                   = fullfile(dataSetDir,strcat('trainingImages',filesep));
% labelDir                   = fullfile(dataSetDir,strcat('trainingLabels',filesep));
% sizeTrainingPatch          = 64;


%imageSize                   = [rows cols];
encoderDepth                = 4;


%%


% These are the data stores with the training pairs and training labels
% They can be later used to create montages of the pairs.
imds                        = imageDatastore(imageDir);
imds2                       = imageDatastore(labelDir);

accuracy(3,3,4) = 0;
jaccard(3,3,4) = 0;




%% U-Net definition and training
numClasses                  = 4 ;

% The class names are a sequence of options for the classes, e.g.
% classNames = ["T1","T2","T3","T4","T5"];
clear classNames
for counterClass=1:numClasses
    classNames(counterClass) = strcat("T",num2str(counterClass));
end
% The labels are simply the numbers of the textures, same numbers
% as with the classNames. For randen examples, these vary 1-5, 1-16, 1-10
labelIDs                    = (1:numClasses);
pxds                        = pixelLabelDatastore(labelDir,classNames,labelIDs);


% training data
trainingData                = pixelLabelImageDatastore(imds,pxds);
%

% Create  U-Net
typeEncoder        = 'adam';
nameEncoder        = '2';
imageSize           = [sizeTrainingPatch sizeTrainingPatch];
numClasses          = 4;
encoderDepth        = 3;
numEpochs           = 15;
lgraph              = unetLayers(imageSize,numClasses,'EncoderDepth',encoderDepth);
opts                = trainingOptions(typeEncoder, ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',numEpochs, ...
    'MiniBatchSize',64);
% Train U-Net
net2                = trainNetwork(trainingData,lgraph,opts);
%% Run segmentation in all slices
% Once the U-Net has been trained, segmentation is performed here:
accuracy(numSlices)     =0;
accuracyN(numSlices)     =0;
jaccardN(numSlices)     =0;
accuracy2(numSlices)     =0;
accuracyN2(numSlices)     =0;
jaccardN2(numSlices)     =0;

%%
for  currentSlice        = 250%1:300 
    disp(currentSlice)
    %currentData         = imread(strcat(baseDirData,'ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    
    [rows,cols]          = size(currentData);
    currentGT           = load (strcat(GTDir,dirGT(currentSlice).name));
    groundTruth         = currentGT.groundTruth;
    % With low memory this can create errors, use the four  quadrants instead
    segmentedData                   = semanticseg(imfilter(currentData,gaussF(3,3,1),'replicate'),net2);
    % Segmentation in four quadrants
    %  Q1                   = semanticseg(imfilter(currentData(1:1000,1:1000),gaussF(3,3,1),'replicate'),net);
    %  Q2                   = semanticseg(imfilter(currentData(1:1000,1001:2000),gaussF(3,3,1),'replicate'),net);
    %  Q3                   = semanticseg(imfilter(currentData(1001:2000,1:1000),gaussF(3,3,1),'replicate'),net);
    %  Q4                   = semanticseg(imfilter(currentData(1001:2000,1001:2000),gaussF(3,3,1),'replicate'),net);
    %  segmentedData        = [Q1 Q2; Q3 Q4];
    
    % %%%%%% Intermediate display of results %%%%%%%
     segmentationAndData                   = labeloverlay(currentData, segmentedData);
     figure; imagesc(segmentationAndData)
    % Convert from semantic to numeric to calculate jaccard and accuracy
    % Result has the following classes:
    % 1 - Nuclear Envelope, 2 - Nucleus, 3-Cell, 4 - Background
    result               = zeros(rows,cols);
    for counterClass=1:numClasses
        result = result +(counterClass*(segmentedData==strcat('T',num2str(counterClass))));
    end

    % Calculate Metrics,
    % Absolute accuracy for all classes
    accuracy(currentSlice)         = sum(sum(result==groundTruth))/rows/cols;
    
    % Accuracy, Jaccard for the Nuclei
    TP                              = (groundTruth==2).*(result==2);
    TN                              = (groundTruth~=2).*(result~=2);
    FP                              = (groundTruth~=2).*(result==2);
    FN                              = (groundTruth==2).*(result~=2);
    
    
    accuracyN(currentSlice)         = (sum(TP(:))+sum(TN(:)))/rows/cols;
    jaccardN(currentSlice)          = (sum(TP(:)))/(sum(TP(:))+sum(FN(:))+sum(FP(:)));
    
    % postProcess
    new_result                      = postProcessHela(result);
    TP2                              = (groundTruth==2).*(new_result==2);
    TN2                              = (groundTruth~=2).*(new_result~=2);
    FP2                              = (groundTruth~=2).*(new_result==2);
    FN2                              = (groundTruth==2).*(new_result~=2);
    
  
    accuracyN2(currentSlice)         = (sum(TP2(:))+sum(TN2(:)))/rows/cols;
    jaccardN2(currentSlice)          = (sum(TP2(:)))/(sum(TP2(:))+sum(FN2(:))+sum(FP2(:)));    
    %jaccard(currentSlice)          = sum(sum( (groundTruth==2).*(result==2) )) / sum(sum ( ((groundTruth==2)|(result==2)) ));

     accuracy(currentSlice)         = sum(sum(new_result==groundTruth))/rows/cols;   
     
     
    %save(strcat(dataSaveDir,filesep,'accuracy','_',num2str(timeSaved(1)),'_',num2str(timeSaved(2)),'_',num2str(timeSaved(3)),'128x128_raw_LPF'),'accuracy','jaccard')   
end
    timeSaved= datevec(date);
    
 %%

subplot(221)
imagesc(repmat(imfilter(currentData,gaussF(3,3,1),'replicate'),[1 1 3]))
subplot(222)
imagesc(groundTruth)
subplot(223) 
imagesc(result)
subplot(224)
imagesc(new_result)
colormap jet
%%
figure
resultRGB        = zeros(rows,cols,3);
resultRGB(:,:,1) = imfilter(currentData,gaussF(3,3,1),'replicate');
resultRGB(:,:,2) = resultRGB(:,:,1).*(result~=2)+0.5*resultRGB(:,:,1).*(result==2);
resultRGB(:,:,3) = resultRGB(:,:,1);


imagesc(resultRGB/255)
