%% Figure Hela Comparison

clear variables
close all
  
  %% Read the files that have been stored in the current folder
if strcmp(filesep,'/')
    % Running in Mac
    %    load('/Users/ccr22/OneDrive - City, University of London/Acad/ARC_Grant/Datasets/DataARC_Datasets_2019_05_03.mat')
    cd ('/Users/ccr22/Acad/GitHub/HeLa_Segmentation_UNET2/CODE')
    %    baseDir                             = 'Metrics_2019_04_25/metrics/';
else
    % running in windows 
    try
        % old HP
        cd ('D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE')
        dataSaveDir = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\Results';
        dataSetDir  = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\';
        GTDir       = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth\';
        baseDirSeg  = 'D:\Acad\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth_4c\';
        baseDirData = 'D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\';
    catch
        %New Alienware
        baseDir = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE';
        baseDirSeg  = strcat(baseDir,filesep,'GroundTruth_4c\');
        cd (baseDir);
        dataSaveDir = strcat(baseDir,filesep,'Results',filesep);
        dataSetDir  = strcat(baseDir,filesep);
        %GTDir       = strcat(baseDir,filesep,'GroundTruth\');
        baseDirSeg2 = strcat(baseDir,filesep,'GroundTruth_multiNuclei\');
        baseDirData = 'C:\Users\sbbk034\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROIS\ROI_1656-6756-329\';
       
    end
end


%%
 load('UNet_128x128_Hela.mat')
  numClasses                  = 4 ;
  rows = 2000;
  cols = 2000;
  


dirSeg                  = dir(strcat(baseDirSeg,'*.mat'));
dirSeg2                  = dir(strcat(baseDirSeg2,'*.mat'));
dirData                 = dir(strcat(baseDirData,'*.tiff'));


%%
%slicesToSegment = [170 220 260];
numSlices                       = numel(dirSeg);
slicesToSegment                 = (1:numSlices);
resultAll (rows,cols,numSlices) = 0;
accuracy1(numSlices)            = 0;
jaccard1(numSlices)             = 0;
accuracy2(numSlices)            = 0;
jaccard2(numSlices)             = 0;
accuracy3(numSlices)            = 0;
jaccard3(numSlices)             = 0;

structEl                        = strel('disk',30);
for slicesT = 1:numSlices 
    currentSlice        = slicesToSegment(slicesT); %260% 1:300
    disp(currentSlice)
            currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
            %currentSeg          = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329_manual\ROI_1656-6756-329_z0',num2str(currentSlice),'.tif'));
            
            currentSeg          = load(strcat(baseDirSeg,dirSeg(currentSlice).name));
            groundTruth         = currentSeg.groundTruth;
            currentSeg2          = load(strcat(baseDirSeg2,dirSeg(currentSlice).name));
            groundTruth2         = currentSeg2.groundTruth;
            
            
            C                   = semanticseg(imfilter(currentData,fspecial('Gaussian',3,1),'replicate'),net);
     %       C                   = semanticseg(imfilter(currentData,gaussF(3,3,1),'replicate'),net);
            
            % Convert from semantic to numeric
            result               = zeros(rows,cols);
            for counterClass=1:numClasses
                %strcat('T',num2str(counterClass))
                %result = result + counterClass*((C==strcat('T',num2str(counterClass))));
                result = result +(counterClass*(C==strcat('T',num2str(counterClass))));
            end
            result2 = imopen(imclose(result==2,structEl),structEl);
            %figure(10*slicesT+currentCase)
            %imagesc(result==maskRanden{currentCase})
            accuracy1(currentSlice)=sum(sum(result==groundTruth))/rows/cols;
            jaccard1(currentSlice) = sum(sum( (groundTruth==2).*(result==2) )) / sum(sum ( ((groundTruth==2)|(result==2)) ));
            accuracy2(currentSlice)=sum(sum(result==groundTruth2))/rows/cols;
            jaccard2(currentSlice) = sum(sum( (groundTruth2==2).*(result==2) )) / sum(sum ( ((groundTruth2==2)|(result==2)) ));
            accuracy3(currentSlice)=sum(sum(result2==(groundTruth2==2)))/rows/cols;
            jaccard3(currentSlice) = sum(sum( (groundTruth2==2).*(result2==1) )) / sum(sum ( ((groundTruth2==2)|(result2==1)) ));
            
            resultAll (:,:,slicesT) = result2;
end

%%
resultRGB        = zeros(rows,cols,3,3);
for slicesT = 1%:3 
    disp(slicesT)
     currentSlice        = slicesToSegment(slicesT); %260% 1:300
     currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
           
     %currentData         = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\',dirData(currentSlice).name));
           
    resultRGB(:,:,1,slicesT) = imfilter(currentData,fspecial('Gaussian',3,1),'replicate');
     %resultRGB(:,:,1,slicesT) = imfilter(currentData,gaussF(3,3,1),'replicate');
    resultRGB(:,:,2,slicesT) = resultRGB(:,:,1,slicesT).*(resultAll (:,:,slicesT)~=2)+0.3*resultRGB(:,:,1).*(resultAll (:,:,slicesT)==2);
    resultRGB(:,:,3,slicesT) = resultRGB(:,:,1,slicesT);
end
%%

% figure(3)
% imagesc((resultAll(:,:,1)==2)+)

%%

%%
h1 =figure(1);
h11=subplot(121);
hp1=plot(1:300, accuracy1, 1:300, accuracy2,1:300, accuracy3,'linewidth',2);
 hp1(2).Color='r';
  hp1(1).Color=[0 0.56448 1];
 hp1(3).Color='k';
  h11.XTick =20:35:266;
  h11.YTick =0.84:0.04:1;
h11.YLim=[0.84 1]; h11.XLim=[20 266];

grid on
title('accuracy')
h12=subplot(122);
hp2=plot(1:300,jaccard1,1:300,jaccard2,1:300,jaccard3,'linewidth',2);
 hp2(2).Color='r';
  hp2(1).Color=[0 0.56448 1];
   hp2(3).Color='k';

    h12.XTick =20:35:266;
h12.YTick =0:0.25:1; h12.XLim=[20 266];
title('jaccard')
grid on
%
h2 =figure(2);
h21=subplot(121);
hp1=plot(1:300, accuracy1, 1:300, accuracy2,1:300, accuracy3,'linewidth',2);
 hp1(2).Color='r';
  hp1(1).Color=[0 0.56448 1];
   hp1(3).Color='k';

h21.XLim=[1 300]; h21.YLim=[0.76 1];
h21.YTick =0.76:0.04:1;
grid on
title('accuracy')
h22=subplot(122);
hp2=plot(1:300,jaccard1,1:300,jaccard2,1:300,jaccard3,'linewidth',2);
 hp2(2).Color='r';
  hp2(1).Color=[0 0.56448 1];
 hp2(3).Color='k';
  
h22.XLim=[1 300];h22.YLim=[0 1];
 h22.YTick =0:0.25:1;
title('jaccard')
grid on
%%
h4=figure(4);
h41=gca;
hp4=plot(1:300,jaccard1,1:300,jaccard2,1:300,jaccard3,'linewidth',2);
 hp4(2).Color='r';
  hp4(1).Color=[0 0.56448 1];
 hp4(3).Color='k';
  
h41.XLim=[75 225];h41.YLim=[0.8 1];
 h41.YTick =0.8:0.05:1;
 h41.XTick =75:25:225;
title('jaccard')
grid on



%%
h1.Position =[ 15         400        1000          300];
h2.Position =[ 15         50        1000          300];
h4.Position = [60 475 850 240];
%%
h11.Position=[0.04 0.09 0.43 0.82];
h21.Position=[0.04 0.09 0.43 0.82];
h12.Position=[0.54 0.09 0.43 0.82];
h22.Position=[0.54 0.09 0.43 0.82];

%%
% h11=subplot(131);
% imagesc(resultRGB(:,:,:,1)/255)
% %axis off
% xlabel('(a)','fontsize',20)
% h12=subplot(132);
% imagesc(resultRGB(:,:,:,2)/255)
% %axis off
% xlabel('(b)','fontsize',20)
% h13=subplot(133);
% imagesc(resultRGB(:,:,:,3)/255)
% %axis off
% xlabel('(c)','fontsize',20)
% %%
% h11.XTick=[];h11.YTick=[];
% h12.XTick=[];h12.YTick=[];
% h13.XTick=[];h13.YTick=[];
% %%
% 
% filename='Three_Unet_Hela_Results.png';
% print('-dpng','-r500',filename)
% 
% 
% h11.Position = [ 0.01    0.12    0.32    0.87];
% h12.Position = [ 0.34    0.12    0.32    0.87];
% h13.Position = [ 0.67    0.12    0.32    0.87];
% 
% 
% %%
% figure(2)
% imagesc(resultRGB(:,:,:,1)/255)
% axis off
% set(gca,'Position',[0 0 1 1]);
% filename='Three_Unet_Hela_Results_1.png';
% print('-dpng','-r500',filename)
% 
% imagesc(resultRGB(:,:,:,2)/255)
% axis off
% set(gca,'Position',[0 0 1 1]);
% filename='Three_Unet_Hela_Results_2.png';
% print('-dpng','-r500',filename)
% 
% 
% imagesc(resultRGB(:,:,:,3)/255)
% axis off
% set(gca,'Position',[0 0 1 1]);
% filename='Three_Unet_Hela_Results_3.png';
% print('-dpng','-r500',filename)