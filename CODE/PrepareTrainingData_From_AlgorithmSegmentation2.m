clear all
close all
%%

cd('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE')
baseDirData         = 'C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\';
dirData             = dir(strcat(baseDirData,'*.tiff'));

%% Select one of the 8,000 slices


% Strategy 3
% patches from 10 x 8000 slices and 10 cells each slice, patches
% are 128x128 with 50 overlap, thus for each slice there are 30x30 patches,
% 900 x 10 x 15 = 135,000
% These will be added to the previous 135,000 to have a total of 270,000


sizeTrainingPatch       = 128;
    structE                 = strel('disk',6);
    structE2                 = strel('disk',2);
%%
for currentSlice        = 230 %:10:370
    disp(currentSlice)   
    %currentSlice        = 330; % 1:numSlices
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    currentOutput = repmat(imfilter(currentData,gaussF(3,3,1),'replicate'),[1 1 3]);

    [rows8000,cols8000]         = size(currentData);
    dataF               = imfilter(currentData,gaussF(3,3,1),'replicate');
    currentOutput = repmat(dataF,[1 1 3]);
    currentOutput1 = zeros(8192,8192);
    currentOutput2 = zeros(8192,8192);
    
    %     figure(1)
    %     imagesc(dataF)
    %     colormap gray
    %     figure(2)
    %     imagesc(dataF(3701:5990,101:3500))
    %     colormap gray

    % Detect the cells in the slice
    %IndividualHelaLabels       = detectNumberOfCells(dataF);
    [IndividualHelaLabels,rankCells,positionROI,helaDistFromBackground2,helaBoundary,helaBackground]    = detectNumberOfCells(dataF);
    % Segment background, nuclei and derive the nuclear envelope
    % imagesc(dataF.*uint8(sum(IndividualHelaLabels,3)))
    %currentData                              = dataF(3701:5700,1501:3500);
    rows                        = 2000;
    cols                        = 2000; 
    % Loop over the cells only those that are not very close to the edges
    %discardCell = find(sum((positionROI>7000)+(positionROI<1000),2));
    %positionROI(discardCell,:) = [];
    %%
    kkk=[1 2 3 4 8 12 15 22 25];
    %currentOutput2 = zeros(8192,8192);
    for counterCell1 = 1:numel(kkk)
        counterCell = kkk(counterCell1);
        disp(counterCell)
        if counterCell<10
            numCell             = strcat('0',num2str(counterCell));
        else
            numCell             = num2str(counterCell);
        end
        
        % location of the cell
        rr                      = positionROI(counterCell,1)-1000:positionROI(counterCell,1)+999;
        cc                      = positionROI(counterCell,2)-1000:positionROI(counterCell,2)+999;
        currentData             = dataF(rr,cc);                 %dataF(2501:4500,3801:5800);
        
        currentOutput1(rr,cc,1) = currentData;
        
        Hela_background         = segmentBackgroundHelaEM(currentData);
        Hela_nuclei             = segmentNucleiHelaEM(    currentData,[],[],Hela_background);

        %     figure
        %     imagesc(currentData +80*uint8(Hela_background)+50*uint8(Hela_nuclei))
        
        Hela_nuclearEnvelope    = imdilate(Hela_nuclei,structE) - imerode(Hela_nuclei,structE2);
%         imagesc(currentData +80*uint8(Hela_background)-50*uint8(Hela_nuclearEnvelope))
        % prepare the ground truth
        %     % Classes:
        %     % 1 - nuclear envelope
        %     % 2 - Nucleus
        %     % 3 - The cell
        %     % 4 - The background is always 1 as it touches the edges of the image,
        %
        %     currentRegions(currentRegions>4)    = 4;
        currentRegions = 1*Hela_nuclearEnvelope+2*Hela_nuclei.*(1-Hela_nuclearEnvelope)+ 4*Hela_background;
        currentRegions(currentRegions==0) =3;
        currentRegions(currentRegions>4) =4;
        %     imagesc(currentRegions)
        currentOutput2(rr,cc,1) = currentRegions;
%         k=1;
  
        
    end
   
    %%
end

%%
figure
h0=gcf;
h1=gca;
hC2 =  imagesc(currentOutput2);
colormap gray
axis off

h1.Position=[0  0 1 1];
h0.Position=[50   50   620   500];

filename = '..\Figures\PreparePatches_ImProcAlgorithm_1.png';
print('-dpng','-r400',filename)
%%
figure
h0=gcf;
h1=gca;
hC2 =  imagesc(currentOutput1);
colormap gray
axis off

h1.Position=[0  0 1 1];
h0.Position=[50   50   620   500];

filename = '..\Figures\PreparePatches_ImProcAlgorithm_2.png';
print('-dpng','-r400',filename)

%%

h0=gcf;
h1=gca;
hC2 =  imagesc(dataF);
colormap gray
axis off

h1.Position=[0  0 1 1];
h0.Position=[50   50   620   500];

filename = '..\Figures\PreparePatches_ImProcAlgorithm_3.png';
print('-dpng','-r400',filename)

