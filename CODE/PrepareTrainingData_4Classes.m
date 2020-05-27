

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


baseDirData             = 'D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\';
baseDirSeg              = 'D:\Acad\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_4c\';
dirData                 = dir(strcat(baseDirData,'*.tiff'));
dirSeg                  = dir(strcat(baseDirSeg,'*.mat'));

% The order in which the GT is read is 1, 10, 100, 2, 20 ... thus it has to be sorted
% In the future it would be better to save GT_001, GT_002 instead GT_1 GT_2
for k=1:300
    posIndex(k,1)=str2num(dirSeg(k).name(10:end-4));
end
[~,realIndex]=sort(posIndex);
    currentData         = imread(strcat(baseDirData,dirData(1).name));
 [rows,cols]         = size(currentData);

%%
sizeTrainingPatch       = 64;
for currentSlice        = 101:2:180
    disp(currentSlice)
    
    % read a slice and its hand-segmented boundary
    %currentData         = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
    %currentSeg          = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329_manual\ROI_1656-6756-329_z0',num2str(currentSlice),'.tif'));
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    currentSeg          = load(strcat(baseDirSeg,dirSeg(realIndex(currentSlice)).name));
    currentRegions      = currentSeg.groundTruth;
    % Calculate the envelope and its centreline
    currentData         = imfilter(currentData,[ 0.0625    0.1250    0.0625; 0.1250    0.2500    0.1250; 0.0625    0.1250    0.0625],'replicate');
        
%     [Hela_background,Background_intensity,Hela_intensity,Hela_output]           = segmentBackgroundHelaEM(currentData);
%     nuclearEnvelope     = imdilate(currentSeg>0,ones(12));
%     nuclearEnvelopeLin  = bwmorph(nuclearEnvelope,'thin','inf');
%     % Create the classes to be used for training
%     % This is for Nucleus/Nuclear Envelope/Else
%     currentRegions1      = bwlabel(nuclearEnvelope==0);
%     % This is for Nucleus/Nuclear Envelope/Cell/Background
%     currentRegions      = 1 * (nuclearEnvelope==1)+...                      % NE
%                           2 * (currentRegions1==2  )+...                    % nucleus
%                           3 * ((currentRegions1==1)-Hela_background)+...    % cell
%                           4 * (Hela_background );                           % background
%                           
%     currentRegions_R    = regionprops(currentRegions,'Area','boundingbox');
%     %
%     % Classes:
%     % 1 - nuclear envelope
%     % 2 - Nucleus
%     % 3 - The cell
%     % 4 - The background is always 1 as it touches the edges of the image,
% 
%     currentRegions(currentRegions>4)    = 4;

    % Strategy 1
    % Iterate over the random points over boundaries and save
    % Create an index of random points along the nuclear envelope
    %[r,c]               = find(nuclearEnvelopeLin);
    % numPoints           = numel(r);
    % numRandom           = round(numPoints/10);
    % indexRand           = sort(1+round(numPoints*rand(numRandom,1)));
    %for cTrainReg = 1:numel(indexRand)
    %    try
    %    trainingRegionRows  = r(indexRand(cTrainReg))-(sizeTrainingPatch/2)+1:r(indexRand(cTrainReg))+sizeTrainingPatch/2;
    %    trainingRegionCols  = c(indexRand(cTrainReg))-(sizeTrainingPatch/2)+1:c(indexRand(cTrainReg))+sizeTrainingPatch/2;
    
    % Strategy 2
    % Iterate over the the whole region and save
    for counterR = 1:sizeTrainingPatch:rows-sizeTrainingPatch
        trainingRegionRows  = counterR:counterR+sizeTrainingPatch-1 ;
        for counterC = 1:sizeTrainingPatch:cols-sizeTrainingPatch
            trainingRegionCols  = counterC:counterC+sizeTrainingPatch-1 ;
            
            % Generate the training data and labels
            currentLabel        = uint8(currentRegions(trainingRegionRows,trainingRegionCols));
            currentSection      = currentData(trainingRegionRows,trainingRegionCols);
            % Numbers, ensure 001, 002, etc
            if currentSlice<10
                numSlice            = strcat('00',num2str(currentSlice));
            elseif currentSlice<100
                numSlice            = strcat('0',num2str(currentSlice));
            else
                numSlice            = num2str(currentSlice);
            end
            if counterR <10
                numcounterR         = strcat('000',num2str(counterR));
            elseif counterR<100
                numcounterR         = strcat('00',num2str(counterR));
            elseif counterR<1000
                numcounterR         = strcat('0',num2str(counterR));
            else
                numcounterR         = num2str(counterR);
            end    
             if counterC <10
                numcounterC         = strcat('000',num2str(counterC));
            elseif counterC<100
                numcounterC         = strcat('00',num2str(counterC));
            elseif counterC<1000
                numcounterC         = strcat('0',num2str(counterC));
            else
                numcounterC         = num2str(counterC);
            end  
            
            % Save training data and labels
            %fName               = strcat('Hela_Data_Slice_',num2str(currentSlice),'_Sample_',num2str(counterR),'_',num2str(counterC),'.png');
            %fNameL              = strcat('Hela_Label_Slice',num2str(currentSlice),'_Sample_',num2str(counterR),'_',num2str(counterC),'.png');
            fName               = strcat('Hela_Data_Slice_',numSlice,'_Sample_',numcounterR,'_',numcounterC,'.png');
            fNameL              = strcat('Hela_Label_Slice',numSlice,'_Sample_',numcounterR,'_',numcounterC,'.png');
            imwrite(currentSection,strcat('trainingImages_4c',filesep,fName))
            imwrite(currentLabel,strcat('trainingLabels_4c',filesep,fNameL))
        end
        %
    end
end