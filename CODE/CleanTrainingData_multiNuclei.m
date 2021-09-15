clear variables
close all
%%
baseDir_HelaCell ='C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329\';
%baseDir_GT       ='C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_4c\';
baseDir_GT       ='C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth_multiNuclei\';
                 
dirHela = dir(strcat(baseDir_HelaCell,'*.tiff'));
dirGT   = dir(strcat(baseDir_GT,'*.mat'));


scrsz=get(0,'screensize');
%%
k=119;      k1=min(k+5,300);k2=max(k-5,1);
currData    = imfilter(imread(strcat(baseDir_HelaCell,dirHela(k).name)),fspecial('Gaussian',3,1));
currDataup  = imfilter(imread(strcat(baseDir_HelaCell,dirHela(k1).name)),fspecial('Gaussian',3,1));
currDatadw  = imfilter(imread(strcat(baseDir_HelaCell,dirHela(k2).name)),fspecial('Gaussian',3,1));
load(strcat(baseDir_GT,dirGT(k).name),'groundTruth');
currClasses(:,:,1) = currData+uint8(groundTruth==2)*100;
currClasses(:,:,2) = currData+uint8(groundTruth==4)*30;
currClasses(:,:,3) = currData+uint8(groundTruth==3)*60;
currClasses(currClasses>255)=255;
h1=figure(1);h11=gca;imagesc(currClasses);grid on;zoom on
h2=figure(2);h21=gca;imagesc(currDatadw);colormap gray;zoom on
h3=figure(3);h31=gca;imagesc(currDataup);colormap gray;zoom on
h1.Position=[300 40 900 730];h2.Position=[1     450 320 330];h3.Position=[1210  450 320 330];
h11.Position=[0.03 0.03 0.95 0.95];h21.Position=[0 0 1 1];h31.Position=[0 0 1 1];
groundTruth2=groundTruth;
%h11.XLim = [0 800];
%h11.YLim = [0 600];
%axis([0 800 0 600])
%%
figure(1);addRegion   = roipoly();
%groundTruth2=groundTruth2-currAdd*(addRegion);
groundTruth2(addRegion>0)=3;
currClasses(:,:,1) = currData+uint8(groundTruth2==2)*100;currClasses(:,:,2) = currData+uint8(groundTruth2==4)*30;
currClasses(:,:,3) = currData+uint8(groundTruth2==3)*60;currClasses(currClasses>255)=255;
imagesc(currClasses)
%%
groundTruth = groundTruth2;
filename    = strcat('GroundTruth_multiNuclei',filesep,'GT_Slice_',num2str(k,'%03d'),'.mat');
save(filename,'groundTruth');
%filename    = strcat('GroundTruth_multiNuclei',filesep,'GT_Slice_',num2str(k+1,'%03d'),'.mat');
%save(filename,'groundTruth');