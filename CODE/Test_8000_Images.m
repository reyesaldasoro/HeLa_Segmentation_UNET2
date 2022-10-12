currentData         = imread('C:\Users\sbbk034\Documents\Acad\Crick\Hela8000_tiff\HeLa_8000_0320.tiff');

filt_g                  = fspecial('Gaussian',5,1);

try
    C1                   = semanticseg(imfilter(currentData(1:4000,1:3000),filt_g,'replicate'),net);
    C2                   = semanticseg(imfilter(currentData(4001:8192,1:3000),filt_g,'replicate'),net);
    C3                   = semanticseg(imfilter(currentData(1:4000,3001:6000),filt_g,'replicate'),net);
    C4                   = semanticseg(imfilter(currentData(4001:8192,3001:6000),filt_g,'replicate'),net);
    C5                   = semanticseg(imfilter(currentData(1:4000,6001:8192),filt_g,'replicate'),net);
    C6                   = semanticseg(imfilter(currentData(4001:8192,6001:8192),filt_g,'replicate'),net);
    C=[C1 C3 C5;C2 C4 C6];
catch
    C1                   = semanticseg(imfilter(currentData(1:2000,1:3000),filt_g,'replicate'),net2);
    C1b                  = semanticseg(imfilter(currentData(2001:4000,1:3000),filt_g,'replicate'),net2);
    C2                   = semanticseg(imfilter(currentData(4001:6000,1:3000),filt_g,'replicate'),net);
    C2b                  = semanticseg(imfilter(currentData(6001:8192,1:3000),filt_g,'replicate'),net);
    
    C3                   = semanticseg(imfilter(currentData(1:2000,3001:6000),filt_g,'replicate'),net);
    C3b                  = semanticseg(imfilter(currentData(2001:4000,3001:6000),filt_g,'replicate'),net);
    C4                   = semanticseg(imfilter(currentData(4001:6000,3001:6000),filt_g,'replicate'),net);
    C4b                  = semanticseg(imfilter(currentData(6001:8192,3001:6000),filt_g,'replicate'),net);

    C5                   = semanticseg(imfilter(currentData(1:2000,6001:8192),filt_g,'replicate'),net);
    C5b                  = semanticseg(imfilter(currentData(2001:4000,6001:8192),filt_g,'replicate'),net);
    C6                   = semanticseg(imfilter(currentData(4001:6000,6001:8192),filt_g,'replicate'),net);
    C6b                  = semanticseg(imfilter(currentData(6001:8192,6001:8192),filt_g,'replicate'),net);

    C=[C1 C3 C5;C1b C3b C5b;C2 C4 C6;C2b C4b C6b];
   
end

figure
imagesc(double(C))