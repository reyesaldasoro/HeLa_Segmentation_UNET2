

%% Clear all variables and close all figures
clear all
close all
clc

%% Read the files that have been stored in the current folder
if strcmp(filesep,'/')
    % Running in Mac
    %    load('/Users/ccr22/OneDrive - City, University of London/Acad/ARC_Grant/Datasets/DataARC_Datasets_2019_05_03.mat')
    cd ('/Users/ccr22/Acad/GitHub/HeLa_Segmentation_UNET/CODE')
    %    baseDir                             = 'Metrics_2019_04_25/metrics/';
else
    % running in windows
    cd ('D:\Acad\GitHub\HeLa_Segmentation_UNET\CODE')
end
%%
sizeTrainingPatch       = 64;
for currentSlice        = 100:2:180
    disp(currentSlice)
    
    % read a slice and its hand-segmented boundary
    currentData         = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
    currentSeg          = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329_manual\ROI_1656-6756-329_z0',num2str(currentSlice),'.tif'));
    % Calculate the envelope and its centreline
    nuclearEnvelope     = imdilate(currentSeg>0,ones(12));
    nuclearEnvelopeLin  = bwmorph(nuclearEnvelope,'thin','inf');
    % Create an index of random points along the nuclear envelope
    [r,c]               = find(nuclearEnvelopeLin);
    numPoints           = numel(r);
    numRandom           = round(numPoints/50);
    indexRand           = sort(1+round(numPoints*rand(numRandom,1)));
    % Create the classes to be used for training
    currentRegions      = bwlabel(nuclearEnvelope==0);
    currentRegions_R    = regionprops(currentRegions,'Area','boundingbox');
    %
    % Classes:
    % 0 - nuclear envelope
    % 1 - The background is always 1 as it touches the edges of the image,
    % 2 - nucleus is 2 and up
    currentRegions(currentRegions>2)    = 2;
    % add one to have labels from 1
    currentRegions      = currentRegions+1;
    % Iterate over the random points and save
    for cTrainReg = 1:numel(indexRand)
        % Generate the training data and labels
        try
        trainingRegionRows  = r(indexRand(cTrainReg))-(sizeTrainingPatch/2)+1:r(indexRand(cTrainReg))+sizeTrainingPatch/2;
        trainingRegionCols  = c(indexRand(cTrainReg))-(sizeTrainingPatch/2)+1:c(indexRand(cTrainReg))+sizeTrainingPatch/2;
        currentLabel        = uint8(currentRegions(trainingRegionRows,trainingRegionCols));
        currentSection      = currentData(trainingRegionRows,trainingRegionCols);
        % Save training data and labels
        fName               = strcat('Hela_Data_Slice_',num2str(currentSlice),'_Sample_',num2str(cTrainReg),'.png');
        fNameL              = strcat('Hela_Label_Slice',num2str(currentSlice),'_Sample_',num2str(cTrainReg),'.png');
        imwrite(currentSection,strcat('trainingImages',filesep,fName))
        imwrite(currentLabel,strcat('trainingLabels',filesep,fNameL))
        catch
        end
        %
    end
end