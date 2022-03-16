load('net_2020_06_24.mat')

dataSaveDir = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\Results';
dataSetDir =  'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\';
GTDir =  'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth\';
%baseDirSeg              = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth_4c\';
baseDirSeg              = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth_4c\';

dirSeg                  = dir(strcat(baseDirSeg,'*.mat'));
%%

currentSlice        = 100;
%currentData         = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));
currentData         = imread(strcat('C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\ROI_1656-6756-329_z0',num2str(currentSlice),'.tiff'));

currentSeg          = load(strcat(baseDirSeg,dirSeg(currentSlice).name));


%%
act1 = activations(net,imfilter(currentData(1:2000,1:2000),ones(3)/9),'conv_1');

%%
sz = size(act1);

%%

imagesc(act1(:,:,17));colorbar

%%
figure
act1 = activations(net,currentData(1:1000,1:1000),'softmax');
act2= mat2gray(act1(1:4:end,1:4:end,:,:));
I = imtile(act2,'GridSize',[2 2]);
imshow(I)

%%
colormap jet
colormap gray
[maxValue,maxValueIndex] = max(max(max(act1)));
plot(maxValue)