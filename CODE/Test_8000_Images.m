currentData         = imread('C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\HeLa_8000_0320.tiff');


C1                   = semanticseg(imfilter(currentData(1:4000,1:3000),fspecial('Gaussian',3,1),'replicate'),net);
C2                   = semanticseg(imfilter(currentData(4001:8192,1:3000),fspecial('Gaussian',3,1),'replicate'),net);
C3                   = semanticseg(imfilter(currentData(1:4000,3001:6000),fspecial('Gaussian',3,1),'replicate'),net);
C4                   = semanticseg(imfilter(currentData(4001:8192,3001:6000),fspecial('Gaussian',3,1),'replicate'),net);
C5                   = semanticseg(imfilter(currentData(1:4000,6001:8192),fspecial('Gaussian',3,1),'replicate'),net);
C6                   = semanticseg(imfilter(currentData(4001:8192,6001:8192),fspecial('Gaussian',3,1),'replicate'),net);


%
C=[C1 C3 C5;C2 C4 C6];

imagesc(double(C))