cd('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE\GroundTruth_multiNuclei\')
dir0=dir('*.mat');
figure
h1=imagesc(ones(2000));set(gca,'position',[0 0 1 1 ]);axis off
colormap gray
%%
clear F
for k=1:300
    load(dir0(k).name)
    if k==1
        groundTruth(1:2,1:2)=1;
    end
    h1.CData=groundTruth;
    caxis([1 4])
    drawnow
    F(k) = getframe(gcf);    
end

%%


    [imGif,mapGif] = rgb2ind(F(1).cdata,256,'nodither');
    numFrames = size(F,2);

    imGif(1,1,1,numFrames) = 0;
    for k = 2:numFrames 
      imGif(:,:,1,k) = rgb2ind(F(k).cdata,mapGif,'nodither');
    end
    %%

    imwrite(imGif,mapGif,'GT_multinuclei.gif',...
            'DelayTime',0,'LoopCount',inf) %g443800
