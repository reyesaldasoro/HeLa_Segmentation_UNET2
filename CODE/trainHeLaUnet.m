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
