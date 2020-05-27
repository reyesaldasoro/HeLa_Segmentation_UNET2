

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

baseDirData             = 'D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\';
baseDirSeg              = 'D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329_manual\';
dirData                 = dir(strcat(baseDirData,'*.tiff'));
dirSeg                  = dir(strcat(baseDirSeg,'*.tif'));
numSlices               = size(dirSeg,1);
currentData             = imread(strcat(baseDirData,dirData(1).name));
[rows,cols]             = size(currentData);
%%
for currentSlice        = 1:numSlices
    
    % read a slice and its hand-segmented boundary
    currentSeg          = imread(strcat(baseDirSeg,dirSeg(currentSlice).name));
    % only read the slice and proceed IF There is manual segmentation
    
    if max(currentSeg(:))==0
        disp(currentSlice)
        
        groundTruth = 4*ones(rows,cols);
                dataOut = strcat('GroundTruth_4c',filesep,'GT_Slice_',num2str(currentSlice));
                save(dataOut,'groundTruth')
    else
        disp(currentSlice)
        % read a slice and its hand-segmented boundary
        currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
        
        % Calculate the envelope and its centreline
        currentData         = imfilter(currentData,[ 0.0625    0.1250    0.0625; 0.1250    0.2500    0.1250; 0.0625    0.1250    0.0625],'replicate');
        
        [rows,cols]         = size(currentData);
        
        [Hela_background,Background_intensity,Hela_intensity,Hela_output]           = segmentBackgroundHelaEM(currentData);
        nuclearEnvelope     = imdilate(currentSeg>0,ones(4));
        nuclearEnvelopeLin  = bwmorph(nuclearEnvelope,'thin','inf');
        % Create the classes to be used for training
        % This is for Nucleus/Nuclear Envelope/Else
        currentRegions1      = bwlabel(nuclearEnvelope==0);
        % This is for Nucleus/Nuclear Envelope/Cell/Background
        currentRegions      = 1 * (nuclearEnvelope==1)+...                      % NE
            2 * (currentRegions1>1  )+...                    % nucleus
            3 * ((currentRegions1==1)-Hela_background)+...    % cell
            4 * (Hela_background );                           % background
        
        currentRegions_R    = regionprops(currentRegions,'Area','boundingbox');
        %
        % Classes:
        % 1 - nuclear envelope
        % 2 - Nucleus
        % 3 - The cell
        % 4 - The background is always 1 as it touches the edges of the image,
        
        currentRegions(currentRegions>4)    = 4;
        groundTruth = currentRegions;
        dataOut = strcat('GroundTruth_4c',filesep,'GT_Slice_',num2str(currentSlice));
        
                        save(dataOut,'groundTruth')
    end
end