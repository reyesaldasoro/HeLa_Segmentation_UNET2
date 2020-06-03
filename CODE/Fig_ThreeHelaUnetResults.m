%% Figure Hela Comparison

clear all
close all
  
  %% Read the files that have been stored in the current folder
if strcmp(filesep,'/')
    % Running in Mac
    %    load('/Users/ccr22/OneDrive - City, University of London/Acad/ARC_Grant/Datasets/DataARC_Datasets_2019_05_03.mat')
    cd ('/Users/ccr22/Acad/GitHub/HeLa_Segmentation_UNET/CODE')
    %    baseDir                             = 'Metrics_2019_04_25/metrics/';
else
    % running in windows
    cd ('D:\Acad\GitHub\HeLa_Segmentation_UNET\CODE')
    dataSaveDir = 'D:\Acad\GitHub\HeLa_Segmentation_UNET\CODE\Results';
    dataSetDir =  'D:\Acad\GitHub\HeLa_Segmentation_UNET\CODE\';
    GTDir =  'D:\Acad\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth\';
end
%%
 load('UNet_128x128_Hela.mat')
  numClasses                  = 4 ;
  rows = 2000;
  cols = 2000;
  

baseDirSeg              = 'D:\Acad\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_4c\';
dirSeg                  = dir(strcat(baseDirSeg,'*.mat'));
baseDirData             = 'D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\';
dirData                 = dir(strcat(baseDirData,'*.tiff'));


%%
slicesToSegment = [170 220 260];

for slicesT = 1:3 
    currentSlice        = slicesToSegment(slicesT); %260% 1:300
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
            resultAll (:,:,slicesT) = result;
end

%%
resultRGB        = zeros(rows,cols,3,3);
for slicesT = 1:3 
     currentSlice        = slicesToSegment(slicesT); %260% 1:300
   
     currentData         = imread(strcat('D:\OneDrive - City, University of London\Acad\AlanTuringStudyGroup\Crick_Data\ROI_1656-6756-329\',dirData(currentSlice).name));
           
resultRGB(:,:,1,slicesT) = imfilter(currentData,gaussF(3,3,1),'replicate');
resultRGB(:,:,2,slicesT) = resultRGB(:,:,1,slicesT).*(resultAll (:,:,slicesT)~=2)+0.3*resultRGB(:,:,1).*(resultAll (:,:,slicesT)==2);
resultRGB(:,:,3,slicesT) = resultRGB(:,:,1,slicesT);
end
%%
h0 =figure;
h0.Position =[ 95         558        1145          420];
%%
h11=subplot(131);
imagesc(resultRGB(:,:,:,1)/255)
%axis off
xlabel('(a)','fontsize',20)
h12=subplot(132);
imagesc(resultRGB(:,:,:,2)/255)
%axis off
xlabel('(b)','fontsize',20)
h13=subplot(133);
imagesc(resultRGB(:,:,:,3)/255)
%axis off
xlabel('(c)','fontsize',20)
%%
h11.XTick=[];h11.YTick=[];
h12.XTick=[];h12.YTick=[];
h13.XTick=[];h13.YTick=[];
%%

filename='Three_Unet_Hela_Results.png';
print('-dpng','-r500',filename)


h11.Position = [ 0.01    0.12    0.32    0.87];
h12.Position = [ 0.34    0.12    0.32    0.87];
h13.Position = [ 0.67    0.12    0.32    0.87];

 
%%
figure(2)
imagesc(resultRGB(:,:,:,1)/255)
axis off
set(gca,'Position',[0 0 1 1]);
filename='Three_Unet_Hela_Results_1.png';
print('-dpng','-r500',filename)

imagesc(resultRGB(:,:,:,2)/255)
axis off
set(gca,'Position',[0 0 1 1]);
filename='Three_Unet_Hela_Results_2.png';
print('-dpng','-r500',filename)


imagesc(resultRGB(:,:,:,3)/255)
axis off
set(gca,'Position',[0 0 1 1]);
filename='Three_Unet_Hela_Results_3.png';
print('-dpng','-r500',filename)
