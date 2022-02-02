%% Clear all variables and close all figures
clear all
close all
clc

%% accuracy_2020_5_15
% Running with 2,300 samples   64x64 patches without LPF, 
%% accuracy_2020_5_16
% Running with 13,300 samples   64x64 patches without/with LPF, 
%% accuracy_2020_5_20
% Running with 38,440 samples   64x64 patches with LPF and four classes 
%% accuracy_2020_5_27
% Running with 19,220 samples   64x64 patches with LPF and four classes 
% After re-arranging GT and file names
%% accuracy_2020_5_28
% Running with 36,000 samples   128x128 patches with LPF and four classes 
% After re-arranging GT and file names




%% Read the files that have been stored in the current folder
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
    
    % running in windows Alienware
    baseDir     = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\';
    cd (strcat(baseDir,'CODE'))
    dataSaveDir = strcat(baseDir,'CODE\Results\');
    dataSetDir  = strcat(baseDir,'CODE\');
    GTDir       = strcat(baseDir,'CODE\GroundTruth\');
    baseDirSeg  = strcat(baseDir,'CODE\GroundTruth_4c\');
    
    dir_8000    = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
    dirSeg                  = dir(strcat(baseDirSeg,'*.mat'));

end
%%
% location of the training data data and labels are stored as pairs of textures arranged in Horizontal,
% Vertical and Diagonal pairs of class 1-2, 1-3, 1-4 ... 2-1, 2-3,...
% imageDir                    = fullfile(dataSetDir,strcat('trainingImages_4c_128',filesep));
% labelDir                    = fullfile(dataSetDir,strcat('trainingLabels_4c_128',filesep));
%sizeTrainingPatch           = 128;

%imageDir                   = fullfile(dataSetDir,strcat('trainingImages_4c',filesep));
%labelDir                   = fullfile(dataSetDir,strcat('trainingLabels_4c',filesep));
%sizeTrainingPatch          = 64;

imageDir                   = fullfile(dataSetDir,strcat('trainingImages',filesep));
labelDir                   = fullfile(dataSetDir,strcat('trainingLabels',filesep));
sizeTrainingPatch          = 64;


%imageSize                   = [rows cols];
encoderDepth                = 4;


%%


% These are the data stores with the training pairs and training labels
% They can be later used to create montages of the pairs.
imds                        = imageDatastore(imageDir);
imds2                       = imageDatastore(labelDir);

accuracy(3,3,4) = 0;
jaccard(3,3,4) = 0;




%% Loop for training and segmentation
% select one of the composite images of the randen cases, there are 9 images
% dimensions of the data
numClasses                  = 4 ;

% The class names are a sequence of options for the textures, e.g.
% classNames = ["T1","T2","T3","T4","T5"];
clear classNames
for counterClass=1:numClasses
    classNames(counterClass) = strcat("T",num2str(counterClass));
end
% The labels are simply the numbers of the textures, same numbers
% as with the classNames. For randen examples, these vary 1-5, 1-16, 1-10
labelIDs                    = (1:numClasses);
pxds                        = pixelLabelDatastore(labelDir,classNames,labelIDs);
for numEpochsName=3  %1:4
    switch numEpochsName
        case 1
            numEpochs       = 5;%10;
        case 2
            numEpochs       = 10;%20;
        case 3
            numEpochs       = 15;%50;
        case 4
            numEpochs       = 20;%100;
    end
    
    % try with different encoders
    for caseEncoder = 2 %  1:3
        switch caseEncoder
            case 1
                typeEncoder     = 'sgdm';
                nameEncoder     = '1';
            case 2
                typeEncoder     = 'adam';
                nameEncoder     = '2';
            case 3
                typeEncoder     = 'rmsprop';
                nameEncoder     = '3';
        end
        
        % Definition of the network to be trained.
        numFilters                  = 64;
        filterSize                  = 3;
        
        for numLayersNetwork =2 %  1:3
            switch numLayersNetwork
                case 1
                    layers = [
                        imageInputLayer([sizeTrainingPatch sizeTrainingPatch 1])
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        maxPooling2dLayer(2,'Stride',2)
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        maxPooling2dLayer(2,'Stride',2)
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
                        convolution2dLayer(1,numClasses);
                        transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
                        convolution2dLayer(1,numClasses);
                        softmaxLayer()
                        pixelClassificationLayer()
                        ];
                    nameLayers     = '15';
                case 2
                    layers = [
                        imageInputLayer([sizeTrainingPatch sizeTrainingPatch 1])
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        maxPooling2dLayer(2,'Stride',2)
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        maxPooling2dLayer(2,'Stride',2)
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        maxPooling2dLayer(2,'Stride',2)
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
                        convolution2dLayer(1,numClasses);
                        transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
                        convolution2dLayer(1,numClasses);
                        transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
                        convolution2dLayer(1,numClasses);
                        softmaxLayer()
                        pixelClassificationLayer()
                        ];
                    
                    nameLayers     = '20';
                case 3
                    layers = [
                        imageInputLayer([sizeTrainingPatch sizeTrainingPatch 1])
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        maxPooling2dLayer(2,'Stride',2)
                        convolution2dLayer(filterSize,numFilters,'Padding',1)
                        reluLayer()
                        transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
                        convolution2dLayer(1,numClasses);
                        softmaxLayer()
                        pixelClassificationLayer()
                        ];
                    
                    nameLayers     = '10';
            end
            %
            
            opts = trainingOptions(typeEncoder, ...
                'InitialLearnRate',1e-3, ...
                'MaxEpochs',numEpochs, ...
                'MiniBatchSize',64);
            
            trainingData        = pixelLabelImageDatastore(imds,pxds);
            %
            net                 = trainNetwork(trainingData,layers,opts);
            % Create alternative U-Net
            
            imageSize = [64 64];
            numClasses = 4;
            encoderDepth = 3;
            lgraph = unetLayers(imageSize,numClasses,'EncoderDepth',encoderDepth);
            net2                = trainNetwork(trainingData,lgraph,opts);
            
            %
            % nameNet             = strcat(dataSaveDir,'Network_Case_',num2str(currentCase),'_Enc_',nameEncoder,'_numL_',nameLayers,'_NumEpochs_',num2str(numEpochs));
            % disp(nameNet)
            %save(nameNet,'net')
            %
            currentSlice        = 100;
            
            currentData         = imread(strcat('C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
            %currentData         = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
            %currentSeg          = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329_manual\ROI_1656-6756-329_z0',num2str(currentSlice),'.tif'));
            currentGT           = load (strcat(GTDir,'GT_Slice_',num2str(currentSlice)));
            groundTruth         = currentGT.groundTruth;
            
            
            currentSeg          = load(strcat(baseDirSeg,dirSeg(currentSlice).name));
            groundTruth         = currentSeg.groundTruth;
            
            
            %C                   = semanticseg(imfilter(currentData,gaussF(3,3,1),'replicate'),net);
                       
            C1                   = semanticseg(imfilter(currentData(1:1000,1:1000),gaussF(3,3,1),'replicate'),net);
            C2                   = semanticseg(imfilter(currentData(1:1000,1001:2000),gaussF(3,3,1),'replicate'),net);
            C3                   = semanticseg(imfilter(currentData(1001:2000,1:1000),gaussF(3,3,1),'replicate'),net);
            C4                   = semanticseg(imfilter(currentData(1001:2000,1001:2000),gaussF(3,3,1),'replicate'),net);
            C=[C1 C2; C3 C4];
            
            %B                   = labeloverlay(currentData, C);
            %figure
            %imagesc(B)
            [rows,cols]          = size(currentData);
            
            % Convert from semantic to numeric
            result               = zeros(rows,cols);
            for counterClass=1:numClasses
                %strcat('T',num2str(counterClass))
                %result = result + counterClass*((C==strcat('T',num2str(counterClass))));
                result = result +(counterClass*(C==strcat('T',num2str(counterClass))));
            end
            %figure(10*counterOptions+currentCase)
            %imagesc(result==maskRanden{currentCase})
            accuracy(numLayersNetwork,caseEncoder,numEpochsName)=sum(sum(result==groundTruth))/rows/cols;
            jaccard(numLayersNetwork,caseEncoder,numEpochsName) = sum(sum( (groundTruth==2).*(result==2) )) / sum(sum ( ((groundTruth==2)|(result==2)) ));
            timeSaved= datevec(date);
            %save(strcat(dataSaveDir,filesep,'accuracy','_',num2str(timeSaved(1)),'_',num2str(timeSaved(2)),'_',num2str(timeSaved(3)),'128x128_raw_LPF'),'accuracy','jaccard')
            disp('----------------------------------------------')
            disp([numEpochsName caseEncoder numLayersNetwork])
            disp('----------------------------------------------')
            disp(accuracy)
        end
    end
end


misclassification = 100*(1-accuracy);

 %% Run segmentation in all slices

baseDirData             = 'D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\';
dirData                 = dir(strcat(baseDirData,'*.tiff'));

%%
for  currentSlice        = 260% 1:300
    disp(currentSlice)
            currentData         = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\',dirData(currentSlice).name));
            %currentSeg          = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329_manual\ROI_1656-6756-329_z0',num2str(currentSlice),'.tif'));
            
            currentSeg          = load(strcat(baseDirSeg,dirSeg(currentSlice).name));
            groundTruth         = currentSeg.groundTruth;
            
            
            C                   = semanticseg(imfilter(currentData,gaussF(3,3,1),'replicate'),net);
            
            % Convert from semantic to numeric
            result               = zeros(rows,cols);
            for counterClass=1:numClasses
                %strcat('T',num2str(counterClass))
                %result = result + counterClass*((C==strcat('T',num2str(counterClass))));
                result = result +(counterClass*(C==strcat('T',num2str(counterClass))));
            end
            %figure(10*counterOptions+currentCase)
            %imagesc(result==maskRanden{currentCase})
            accuracy2(currentSlice)=sum(sum(result==groundTruth))/rows/cols;
            jaccard2(currentSlice) = sum(sum( (groundTruth==2).*(result==2) )) / sum(sum ( ((groundTruth==2)|(result==2)) ));
end

%%
figure
resultRGB        = zeros(rows,cols,3);
resultRGB(:,:,1) = imfilter(currentData,gaussF(3,3,1),'replicate');
resultRGB(:,:,2) = resultRGB(:,:,1).*(result~=2)+0.5*resultRGB(:,:,1).*(result==2);
resultRGB(:,:,3) = resultRGB(:,:,1);


imagesc(resultRGB/255)
