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
imagesc(imfilter(Hela8000,gaussF(9,9,1),'replicate'))
axis([1 7000 4000 7400 ])
 set(gca,'position',[0 0 1 1 ]);axis off
colormap gray

set(gcf,'Position',[50 150 789 341])
print('-dpng','-r400','Result_8000_330_raw_2022_03_03_B.png')
%% 
% 151 == 330 
testSlices = [48 71 151  215 251];  %  82170
clear h
for  k=1:5
    currentSlice        = testSlices(k);
    disp(currentSlice)
    %currentData         = imread(strcat(baseDirData,'ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    h{k} = subplot(1,5,k);
    imagesc(imfilter(currentData,gaussF(5,5,1),'replicate'))
    axis off
end
colormap gray

%%
% h{1}.Position=[0.01         0.01 0.1925 0.98];
% h{2}.Position=[0.01+0.155*1 0.01 0.1925 0.98];
% h{3}.Position=[0.01+0.155*2 0.01 0.1925 0.98];
% h{4}.Position=[0.01+0.155*3 0.01 0.1925 0.98];
% h{5}.Position=[0.01+0.155*4 0.01 0.1925 0.98];
% h{6}.Position=[0.01+0.155*5 0.01 0.1925 0.98];
%%
fSize   = 14;
h{1}.Position=[0.01        0.01 0.1925 0.9];
h{2}.Position=[0.01+0.1975*1 0.01 0.1925 0.9];
h{3}.Position=[0.01+0.1975*2 0.01 0.1925 0.9];
h{4}.Position=[0.01+0.1975*3 0.01 0.1925 0.9];
h{5}.Position=[0.01+0.1975*4 0.01 0.1925 0.9];

h{1}.Title.FontSize=fSize; h{1}.Title.String='(a)';
h{2}.Title.FontSize=fSize; h{2}.Title.String='(b)';
h{3}.Title.FontSize=fSize; h{3}.Title.String='(c)';
h{4}.Title.FontSize=fSize; h{4}.Title.String='(d)';
h{5}.Title.FontSize=fSize; h{5}.Title.String='(e)';



%%
set(gcf,'Position',[50 150 789 231])
print('-dpng','-r400','Fig_2C_MIUA_2022.png')
