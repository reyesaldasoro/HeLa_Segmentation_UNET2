function new_result = postProcessHela(result)
% Postprocess to improve results, first the nucleus, remove small specs and
% close then remove small regions that are not nuclei
nuclei_0    = result==2;
nuclei_1    = bwlabel(imclose(imfill(nuclei_0,'holes'),strel('disk',3) ));
nuclei_1p   = regionprops(nuclei_1,'area');
% For 2000x2000 at 10nm .5% of area is  0.0008*rows*cols = 2000
nuclei_2    = ismember(nuclei_1,find([nuclei_1p.Area]>3200));
%result222((result==2)&(nuclei_2==0))=3;
%imagesc(2*nuclei_0+nuclei_2)
%%
% reassign the regions of nuclei that have been removed, to cell
cell            = result==3;

cell(imdilate(nuclei_2<nuclei_0,ones(3))) =1;
cell(nuclei_2>nuclei_0) =0;
%imagesc(2*cell+(result==3))
%%
% Next, complete nuclear envelope
nuclear_env_0       = result==1;
% find overlap in dilated regions of nuclei and cell (there must be a
% nuclear envelope there)
sizeDil = 7;
overlap_Nuc_Cell    = imdilate(cell,ones(sizeDil)).*imdilate(nuclei_2,ones(sizeDil));
% combine the overlap and the original to complete perimeters
nuclear_env_1       = bwlabel(nuclear_env_0+overlap_Nuc_Cell);
nuclear_env_1p      = regionprops(nuclear_env_1,'area','perimeter');
% keep only large sections
% For 2000x2000 at 10nm .2% of area is  0.0002*rows*cols = 800
nuclear_env_2       = ismember(nuclear_env_1,find([nuclear_env_1p.Area]>800));

% with the previous results, recalculate nuclei, that is, remove the
% nuclear envelope
nuclei_3    = nuclei_2.*(1-nuclear_env_2);
% recalculate cell, same, remove nuclear envelope but add those regions of
% nuclear envelope that were previously removed
cell_2      = cell.*(1-nuclear_env_2); 
cell_2(nuclear_env_0>nuclear_env_2) =1;
cell_3      = cell_2.*(1-nuclei_3);

background  = (result==4).*(1-cell_3).*(1-nuclei_3).*(1-nuclear_env_2 );
new_result  = nuclear_env_2+2*nuclei_3+3*cell_3+4*background;
%imagesc(new_result)