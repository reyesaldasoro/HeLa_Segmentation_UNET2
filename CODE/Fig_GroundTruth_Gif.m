%% Figure Hela four class ground truth

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
    GTDir =  'D:\Acad\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_4c\';
end
%%


dir0 = dir (strcat(GTDir,'*.mat'));

numFiles = size(dir0,1);
%%
h0=figure(1);
h1=cla;
h2=imagesc(zeros(2000,2000));
colormap gray

h1.Position=([0 0 1 1]);
axis off
%%
clear F;
for k=1:numFiles
    load(strcat(GTDir,dir0(k).name))
    h2.CData = uint8(255*groundTruth/4);
    %caxis([1 4])
    caxis([0 255])
    drawnow
    F(k)= getframe;
    %imwrite(groundTruth/4,strcat('GroundTruth_4c_tif',filesep,'GT_Slice_',num2str(k),'.tif'))
end

  %% save the movie as a GIF
    [imGif,mapGif] = rgb2ind(F(118).cdata,256,'nodither');
    numFrames = size(F,2);
    %%
% mapGif=[0 0 0; 0.3 0.3 0.3;0.6 0.6 0.6;1 1 1];

    imGif(1,1,1,numFrames) = 0;
    for k = 2:numFrames 
      imGif(:,:,1,k) = rgb2ind(F(k).cdata,mapGif,'nodither');
    end
    %%

    imwrite(imGif,mapGif,'GT_Hela_4classesK.gif',...
            'DelayTime',0,'LoopCount',inf) %g443800