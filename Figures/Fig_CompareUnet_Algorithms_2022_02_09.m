%%  Recover data from Figure in PLOS Paper


%
uiopen('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa-Cell-Segmentation\MatlabFigs\PLOS_Fig7_latest.fig',1)

h0=gcf;
% get the axes
h1=h0.Children(1);
h2=h0.Children(2);
h3=h0.Children(4);

% get values
x1=h1.Children(1).XData;
a_inc=h1.Children(1).YData;
a_res=h1.Children(2).YData;
a_vgg=h1.Children(3).YData;
a_ImPr=h1.Children(4).YData;
x2=h2.Children(1).XData;
j_inc=h2.Children(1).YData;
j_res=h2.Children(2).YData;
j_vgg=h2.Children(3).YData;
j_ImPr=h2.Children(4).YData;

%
close(figure(1))
%
%x1=1:numel(a1);
%x2=1:numel(j1);
figure(2)
hold on
hp1=plot(x1,a_inc,'b--','linewidth',2);
hp2=plot(x1,a_res,'r-');
hp3=plot(x1,a_vgg,'-','color',[1 1 1]*0.4);
hp4=plot(x1,a_ImPr,'k','linewidth',2);
hold off
close(figure(2))
%
figure(3)
%plot(x2,j1,x2,j2,x2,j3,x2,j4)
hold on
hp1=plot(x2,j_inc,'b--','linewidth',2);
hp2=plot(x2,j_res,'r-');
hp3=plot(x2,j_vgg,'-','color',[1 1 1]*0.4);
hp4=plot(x2,j_ImPr,'k','linewidth',2);
hold off

close(figure(3))

%%
%load Results_Seg_Unet_Hela_multinuclei_2022_02_04
load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE\Results\accuracy_2022_2_9_128x128_135000.mat')
accuracy1_135 = accuracy1;
accuracy2_135 = accuracy2;
accuracy3_135 = accuracy3;
jaccard1_135  = jaccard1;
jaccard2_135  = jaccard2;
jaccard3_135  = jaccard3;

load('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\HeLa_Segmentation_UNET2\CODE\Results\accuracy_2022_2_4_128x128_36000.mat')


%%
% h1 =figure(1);
% h11=subplot(121);
% %hp1=plot(1:300, accuracy1, 1:300, accuracy2,1:300, accuracy3,'linewidth',2);
% hp1=plot(1:300, accuracy1, 1:300, accuracy2,'linewidth',2);
%  hp1(2).Color='r';
%   hp1(1).Color=[0 0.56448 1];
% % hp1(3).Color='k';
%   h11.XTick =20:35:266;
%   h11.YTick =0.84:0.04:1;
% h11.YLim=[0.84 1]; h11.XLim=[20 266];
% 
% 
% grid on
% title('accuracy')
% h12=subplot(122);
% %hp2=plot(1:300,jaccard1,1:300,jaccard2,1:300,jaccard3,'linewidth',2);
% hp2=plot(1:300,jaccard1,1:300,jaccard2,'linewidth',2);
%  hp2(2).Color='r';
%   hp2(1).Color=[0 0.56448 1];
%  %  hp2(3).Color='k';
% 
%     h12.XTick =20:35:266;
% h12.YTick =0:0.25:1; h12.XLim=[20 266];
% title('jaccard')
% grid on
%%

x2 = [1:19 x1 266:300];
a_ImPr2 = [ones(1,19) a_ImPr ones(1,35)];
h7 =figure(11);
cla
%h21=subplot(121);
h111=gca;
hold on
hp11=plot(1:300, accuracy1,'linewidth',2,'color',[0 0.56448 1]);
hp12=plot(1:300, accuracy3,'linestyle',':','linewidth',2,'color',[1 0 0]);
hp13=plot(1:300, accuracy3_135,'linestyle','-','linewidth',3,'color',[0 0.6 0]);
hp4 =plot(x2,a_ImPr2,'k','linestyle','--','linewidth',1);
hold off


h111.XLim=[0 301]; h111.YLim=[0.87 1.001];
h111.YTick =0.78:0.02:10.1;
grid on
ylabel('Accuracy','fontsize',18)
xlabel('Slice','fontsize',18)
h7.Position =[ 15         400        1000          300];
hLeg= legend('U-Net Single Nucleus','U-Net Multiple Nuclei, Training 101:2:180','U-Net Multiple Nuclei, Training     1:2:300','Image Processing Algorithm','location','s');
 hLeg.FontSize = 12;
%
h111.Position=[0.07 0.18 0.91 0.77];
filename = 'Fig_CompareUnet_Algorithms_2022_02_09_Accuracy.png';

%%
h8 =figure(28);
cla
h222=gca;
%h22=subplot(122);
hold on
hp21=plot(1:300,jaccard1,'linewidth',2,'color',[0 0.56448 1]);
hp22=plot(1:300,jaccard3,'linestyle',':','linewidth',2,'color',[1 0 0]);
hp23=plot(1:300,jaccard3_135,'linewidth',3,'color',[0 0.6 0]);

hp27=plot(x2,j_ImPr,'k','linestyle','--','linewidth',1);
hold off
  
h222.XLim=[0 301];h222.YLim=[0 1];
 h222.YTick =0:0.1:1;
%title('jaccard')
ylabel('Jaccard Index','fontsize',18)
xlabel('Slice','fontsize',18)
grid on

h8.Position =[ 15         100        1000          300];

h222.Position=[0.07 0.18 0.91 0.77];

%hLeg= legend('U-Net Single Nucleus','U-Net Multiple Nucleus','U-Net Multiple Nucleus+post processing','Image Processing Algorithm','location','s');
hLeg= legend('U-Net Single Nucleus','U-Net Multiple Nuclei, Training 101:2:180','U-Net Multiple Nuclei, Training     1:2:300','Image Processing Algorithm','location','s');

 hLeg.FontSize = 12;
filename = 'Fig_CompareUnet_Algorithms_2022_02_09_Jaccard.png';

%% 
 
 range = 60:150;

[mean(jaccard1(range)) mean(jaccard3(range)) mean(jaccard3_135(range)) mean(j_ImPr(range))]
[mean(accuracy1(range)) mean(accuracy3(range)) mean(accuracy3_135(range)) mean(a_ImPr2(range))]
%%
 
%
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
range = 160:200;

[mean(jaccard1(range)) mean(jaccard3(range)) mean(jaccard3_135(range)) mean(j_ImPr(range))]
[mean(accuracy1(range)) mean(accuracy3(range)) mean(accuracy3_135(range)) mean(a_ImPr2(range))]
%%

