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
for currentSlice        = 230:10:370
    disp(currentSlice)   
    %currentSlice        = 330; % 1:numSlices
    currentData         = imread(strcat(baseDirData,dirData(currentSlice).name));
    currentOutput = repmat(imfilter(currentData,gaussF(3,3,1),'replicate'),[1 1 3]);

    [rows8000,cols8000]         = size(currentData);
    dataF               = imfilter(currentData,gaussF(3,3,1),'replicate');
    currentOutput = repmat(dataF,[1 1 3]);
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
    discardCell = find(sum((positionROI>7000)+(positionROI<1000),2));
    positionROI(discardCell,:) = [];
    for counterCell = 1:max(10,numel(positionROI,1))
        if counterCell<10
            numCell             = strcat('0',num2str(counterCell));
        else
            numCell             = num2str(counterCell);
        end
        
        % location of the cell
        rr                      = positionROI(counterCell,1)-1000:positionROI(counterCell,1)+999;
        cc                      = positionROI(counterCell,2)-1000:positionROI(counterCell,2)+999;
        currentData             = dataF(rr,cc);                 %dataF(2501:4500,3801:5800);
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
        
%         k=1;
        for counterR = 1:sizeTrainingPatch/2:rows-sizeTrainingPatch
            trainingRegionRows  = counterR:counterR+sizeTrainingPatch-1 ;
            for counterC = 1:sizeTrainingPatch/2:cols-sizeTrainingPatch
                trainingRegionCols  = counterC:counterC+sizeTrainingPatch-1 ;
                
                % Generate the training data and labels
                currentLabel        = uint8(currentRegions(trainingRegionRows,trainingRegionCols));
                currentSection      = currentData(trainingRegionRows,trainingRegionCols);
                % Numbers, ensure 001, 002, etc
                if currentSlice<10
                    numSlice            = strcat('00',num2str(currentSlice));
                elseif currentSlice<100
                    numSlice            = strcat('0',num2str(currentSlice));
                else
                    numSlice            = num2str(currentSlice);
                end
                if counterR <10
                    numcounterR         = strcat('000',num2str(counterR));
                elseif counterR<100
                    numcounterR         = strcat('00',num2str(counterR));
                elseif counterR<1000
                    numcounterR         = strcat('0',num2str(counterR));
                else
                    numcounterR         = num2str(counterR);
                end
                if counterC <10
                    numcounterC         = strcat('000',num2str(counterC));
                elseif counterC<100
                    numcounterC         = strcat('00',num2str(counterC));
                elseif counterC<1000
                    numcounterC         = strcat('0',num2str(counterC));
                else
                    numcounterC         = num2str(counterC);
                end

                % Save training data and labels
                %fName               = strcat('Hela_Data_Slice_',num2str(currentSlice),'_Sample_',num2str(counterR),'_',num2str(counterC),'.png');
                %fNameL              = strcat('Hela_Label_Slice',num2str(currentSlice),'_Sample_',num2str(counterR),'_',num2str(counterC),'.png');
                fName               = strcat('Hela_Data_8000_Slice_',numSlice,'_Cell_',numCell,'_Sample_',numcounterR,'_',numcounterC,'.png');
                fNameL              = strcat('Hela_Label_8000_Slice_'numSlice,'_Cell_',numCell,'_Sample_',numcounterR,'_',numcounterC,'.png');
                imwrite(currentSection,strcat('trainingImages_4c_128_plus_8000',filesep,fName))
                imwrite(currentLabel,strcat('trainingLabels_4c_128_plus_8000',filesep,fNameL))
%                 a(:,:,k)=currentSection;
%                 b(:,:,k)=currentLabel;
%                 k=k+1;
            end
        end
    end
end


