% Fig training data


clear variables
close all

%% Read the files that have been stored in the current folder
%New Alienware
baseDir = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE';
baseDirSeg  = strcat(baseDir,filesep,'GroundTruth_4c\');
cd (baseDir);
dataSaveDir = strcat(baseDir,filesep,'Results',filesep);
dataSetDir  = strcat(baseDir,filesep);
%GTDir       = strcat(baseDir,filesep,'GroundTruth\');
baseDirSeg2 = strcat(baseDir,filesep,'GroundTruth_multiNuclei\');
baseDirData = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329\';
dirData         = dir(strcat(baseDirData,'*.tiff'));
dirGT           = dir(strcat(baseDirSeg2,'*.mat'));
dirPatchesD      = dir(strcat(baseDir,filesep,'trainingImages_4c_128\*.png'));
dirPatchesL      = dir(strcat(baseDir,filesep,'trainingLabels_4c_128\*.png'));
dirPatchesD2      = dir(strcat(baseDir,filesep,'trainingImages_4c_128_plus_8000\*.png'));
dirPatchesL2      = dir(strcat(baseDir,filesep,'trainingLabels_4c_128_plus_8000\*.png'));


%% First, create a line with the patches from manual segmentation

%clf
currentSlice    = 119;
data_2000        = imread(strcat(baseDirData,dirData(currentSlice).name));
GT_2000         = load(strcat(baseDirSeg2,dirGT(currentSlice).name));
% imagesc(GT_2000.groundTruth)

clear patchL patchT
biasP =25596;
numPatches = 16;
rows=128;
cols=128;
patchT = zeros(rows,cols,numPatches);
patchL = zeros(rows,cols,numPatches);
for k=biasP+(1:numPatches)
    patchT(:,:,-biasP+k) = imread(strcat(baseDir,filesep,'trainingImages_4c_128\',dirPatchesD(k).name));
    patchL(:,:,-biasP+k) = imread(strcat(baseDir,filesep,'trainingLabels_4c_128\',dirPatchesL(k).name));
    %patchT(2:129,2:129,-biasP+k) = imread(strcat(baseDir,filesep,'trainingImages_4c_128\',dirPatchesD(k).name));
    %patchL(2:129,2:129,-biasP+k) = imread(strcat(baseDir,filesep,'trainingLabels_4c_128\',dirPatchesL(k).name));
end
%patchBoth=patchT;
%patchBoth(:,:,33:64)=60*patchL;
patchT(end-4:end,:)=0;  
patchL(end-4:end,:)=0;  
patchT(:,end-3:end,:)=0;  
patchL(:,end-3:end,:)=0;  
%%

patchT2 = zeros(rows,cols,numPatches);
patchL2 = zeros(rows,cols,numPatches);
biasP =25589;

for k=biasP+(1:numPatches)
    patchT2(:,:,-biasP+k) = imread(strcat(baseDir,filesep,'trainingImages_4c_128_plus_8000\',dirPatchesD2(k).name));
    patchL2(:,:,-biasP+k) = imread(strcat(baseDir,filesep,'trainingLabels_4c_128_plus_8000\',dirPatchesL2(k).name));
    %patchT(2:129,2:129,-biasP+k) = imread(strcat(baseDir,filesep,'trainingImages_4c_128\',dirPatchesD(k).name));
    %patchL(2:129,2:129,-biasP+k) = imread(strcat(baseDir,filesep,'trainingLabels_4c_128\',dirPatchesL(k).name));
end
%patchBoth=patchT;
%patchBoth(:,:,33:64)=60*patchL;
patchT2(end-4:end,:)=0;  
patchL2(end-4:end,:)=0;  
patchT2(:,end-3:end,:)=0;  
patchL2(:,end-3:end,:)=0;
%montage(uint8(patchL2*60))
%%
  
h0 = gcf;
clf

h1= subplot(231);
imagesc(imfilter(data_2000,gaussF(3,3,1),'replicate'));
ht1 = title('Region of interest');
axis off

h2= subplot(232);
imagesc(GT_2000.groundTruth);
ht2 = title('Manual Segmentation');
axis off

h3 = subplot(4,3,3);
 montage(uint8(patchT))
 axis normal
 ht3 = title('Training pairs');

 h4 = subplot(4,3,6);
 montage(uint8(patchL*60))
axis normal


colormap gray
 
%%
    baseDir         = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\';
    baseDirData     = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
    dirData         = dir(strcat(baseDirData,'*.tiff'));


currentSlice        =330;% 1:numSlices 
 
    %currentData         = imread(strcat(baseDirData,'ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    
    [rows,cols]          = size(currentData);
dataF               = imfilter(currentData,gaussF(3,3,1),'replicate');

%%

a1= imread('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Figures\PreparePatches_ImProcAlgorithm_3.png');
a2= imread('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\Figures\PreparePatches_ImProcAlgorithm_1.png');
%%
h5= subplot(234);
imagesc(a1);
ht1 = title('Whole dataset');
axis off

h6= subplot(235);
imagesc(a2);
ht2 = title('Automatic Segmentation');
axis off
%%

 h7 = subplot(4,3,9);
 montage(uint8(patchT2))
 axis normal
 ht3 = title('Training pairs');

 h8 = subplot(4,3,12);
 montage(uint8(patchL2*60))
axis normal

%%

h0.Position =[ 80  300  1000  400];
h1.Position = [0.03 0.51 0.3 0.45];
h5.Position = [0.03 0.02 0.3 0.45];
h2.Position = [0.35 0.51 0.3 0.45];
h6.Position = [0.35 0.02 0.3 0.45];
%%
h3.Position = [0.67 0.75 0.3 0.21];
h4.Position = [0.67 0.51 0.3 0.21];
h7.Position = [0.67 0.26 0.3 0.21];
h8.Position = [0.67 0.02 0.3 0.21];

%%
filename = 'Figures/Generation_trainingDataUnet.png';
print('-dpng','-r400',filename)
