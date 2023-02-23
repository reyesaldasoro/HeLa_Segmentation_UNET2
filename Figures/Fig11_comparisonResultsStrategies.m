
clear 
close all
%%

baseDir = 'C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE\Figures\';

images{1} = 'Result_8000_330_Unet_36000_2022_10_19.png';
images{2} = 'Result_8000_330_Unet_135000_2022_10_19.png';
images{3} = 'Result_8000_330_Unet_135000ImProc_2023_01_25.png';
images{4} = 'Result_8000_330_Unet_270000_2022_10_19.png';
images{5} = 'Result_8000_330_ImProc_2022_02_08_C.png';

for k=1:5
    h0 = figure(k);
    clf
    h0.Position= [180    270    1000    450];
    %h0.Position=[0 0 1 1 ];
    currImage = imread(strcat(baseDir,images{k}));
    imagesc(currImage)



    a1a=annotation(gcf,'arrow',[0.282  0.256],  [0.386 0.323]);
    a1b=annotation(gcf,'arrow',[0.282  0.2514],  [0.386 0.177]);
    a1c=annotation(gcf,'arrow',[0.282  0.2834],  [0.386 0.253]);
    a1a.LineWidth =2;
    a1b.LineWidth =2;
    a1c.LineWidth =2;
    

    a2a = annotation(gcf,'arrow',[0.6938 0.729],  [0.54966 0.64]);
    a2b = annotation(gcf,'arrow',  [0.8506 0.87], [0.640333 0.80]);
    a2a.LineStyle='--';a2a.LineWidth=2;
    a2b.LineStyle='--';a2b.LineWidth=2 ;

    a3 =  annotation(gcf,'arrow',[0.217 0.2994],...
    [0.848333333333333 0.664444444444444]);

    a4 = annotation(gcf,'arrow',[0.7066 0.8338],...
    [0.0447777777777778 0.0457777777777778]);

    a3.LineStyle=':';a3.LineWidth=2 ;
    a4.LineStyle='-.';a4.LineWidth=1 ;
    h1 = gca;
    h1.Position=[0 0 1 1];

    %axis([1 7000 4000 7400])
    axis off

    filename = strcat(baseDir,'Result_8000_arrows',images{k}(12:end));

    print('-dpng','-r400',filename)
end