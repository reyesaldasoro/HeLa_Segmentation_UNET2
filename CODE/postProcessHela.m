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
cell0            = result==3;
cell             = cell0;
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
%%

% h1 = subplot(345);
% imagesc(result)
% h2 = subplot(342);
% imagesc(nuclei_0)
% h3 = subplot(343);
% imagesc(nuclei_3)
% h4 = subplot(346);
% imagesc(cell0)
% h5 = subplot(347);
% imagesc(cell)
% h6 = subplot(3,4,10);
% imagesc(nuclear_env_0)
% h7 = subplot(3,4,11);
% imagesc(nuclear_env_2)
% h8 = subplot(3,4,8);
% imagesc(new_result)
% %%
% rr1 = 3200;
% rr2 = 4100;
% cc1 =  800;
% cc2 = 1700;
% h1.XLim= [cc1        cc2]; h1.YLim= [rr1        rr2];
% h2.XLim= [cc1        cc2]; h2.YLim= [rr1        rr2];
% h3.XLim= [cc1        cc2]; h3.YLim= [rr1        rr2];
% h4.XLim= [cc1        cc2]; h4.YLim= [rr1        rr2];
% h5.XLim= [cc1        cc2]; h5.YLim= [rr1        rr2];
% h6.XLim= [cc1        cc2]; h6.YLim= [rr1        rr2];
% h7.XLim= [cc1        cc2]; h7.YLim= [rr1        rr2];
% h8.XLim= [cc1        cc2]; h8.YLim= [rr1        rr2];
% %%
% h1.Position = [ 0.01    0.3    0.26    0.47];
% h8.Position = [ 0.725    0.3    0.26    0.47];
% 
% h2.Position = [ 0.28    0.66    0.215    0.30];
% h3.Position = [ 0.50    0.66    0.215    0.3];
% h4.Position = [ 0.28    0.34    0.215    0.30];
% h5.Position = [ 0.50    0.34    0.215    0.3];
% h6.Position = [ 0.28    0.02    0.215    0.30];
% h7.Position = [ 0.50    0.02    0.215    0.30];
% %%
% 
% h1.XTick=[];h1.YTick=[];
% h2.XTick=[];h2.YTick=[];
% h3.XTick=[];h3.YTick=[];
% h4.XTick=[];h4.YTick=[];
% h5.XTick=[];h5.YTick=[];
% h6.XTick=[];h6.YTick=[];
% h7.XTick=[];h7.YTick=[];
% h8.XTick=[];h8.YTick=[];
% 
% colormap gray
% %%
% filename = 'Figures/PostProcessing_Unet.png';
% print('-dpng','-r400',filename)