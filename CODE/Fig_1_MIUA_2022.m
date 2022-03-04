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

    baseDirSeg  = strcat(baseDir,'CODE\GroundTruth_4c\');
    
    dir0_8000    = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
    dir_8000    = dir(strcat(dir0_8000,'*.tiff'));
    
    dirSeg      = dir(strcat(baseDirSeg,'*.mat'));
    GTDir       = strcat(baseDir,'CODE\GroundTruth_4c\');
    dirGT       = dir(strcat(GTDir,'*.mat'));
    GTDir_multi       = strcat(baseDir,'CODE\GroundTruth_multiNuclei\');
    dirGT_multi       = dir(strcat(GTDir_multi,'*.mat'));
end


numSlices       = numel(dirGT_multi);
%%
currentSlice=330;
Hela8000 = imread(strcat(dir0_8000,dir_8000(currentSlice).name));
imagesc(imfilter(Hela8000,gaussF(5,5,1),'replicate'))
axis([1 7000 4000 7400 ])
 set(gca,'position',[0 0 1 1 ]);axis off
colormap gray

set(gcf,'Position',[50 150 789 341])
print('-dpng','-r400','Fig_1_MIUA_2022.png')
