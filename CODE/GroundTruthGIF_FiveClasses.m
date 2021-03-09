%% Generate GIF of the five classes


baseDir     = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_5c_tif';
baseDir2     = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET\CODE\GroundTruth_5c';
dir0        = dir(strcat(baseDir,filesep,'*.t*'));
dir2        = dir(strcat(baseDir2,filesep,'*.m*'));

numFiles    = size(dir0,1);


figure
%%
currentData(2000,2000,300)=0;
%%
for k=1:numFiles
    %temp = load((strcat(baseDir2,filesep,dir2(k).name)));
    %currentData(:,:,k) = temp.groundTruth;
    imagesc(currentData(:,:,k))
    caxis([1 5])
    pause(0.01)
    drawnow
end
%%
currentData3=medfilt3(currentData,[1 1 3]);


%%
currentImages(2000,2000,300)=0;

for k=1:numFiles
    currentImages(:,:,k) =  imfilter(imread(strcat(baseDir,filesep,dir0(k).name)),ones(3)/9);
    imagesc(currentImages(:,:,k))
    pause(0.01)
    drawnow
end

%% 
currentData3=medfilt3(currentImages,[1 1 3]);
%%
clear F
for k=1:numFiles
    imagesc(currentData(:,:,k))
    axis off
    caxis([1 5])
    pause(0.1)
    drawnow
    F(k) = getframe(gcf);
end

%%

clear *Gif
fStep = 1;
fStep2= 1;
 [imGif,mapGif] = rgb2ind(F(119).cdata(1:fStep:end,1:fStep:end,:),256,'nodither');
    numFrames = size(F,2);

    imGif(1,1,1,floor(numFrames/fStep2)) = 0;
    for k = 1:fStep2:numFrames 
      imGif(:,:,1,k/fStep2) = rgb2ind(F(k).cdata(1:fStep:end,1:fStep:end,:),mapGif,'nodither');
    end
    %%

    imwrite(imGif,mapGif,'groundTruth_5c.gif',...
            'DelayTime',0,'LoopCount',inf) %g443800