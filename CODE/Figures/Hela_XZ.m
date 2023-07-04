clear 
close all
%%
dir0= dir('Hela3D*');

HeLa(2048,2048,510) = uint8(0);

%%

for k = 1 :17
    a=load(dir0(k).name);
    b=fieldnames(a);
    c =  getfield(a,b{1});
    HeLa(:,:,(k-1)*30+(1:30)) = c(1:4:end,1:4:end,:);
    clear a b c
    disp(k)
end