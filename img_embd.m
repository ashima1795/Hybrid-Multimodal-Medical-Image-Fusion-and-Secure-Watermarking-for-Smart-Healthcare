%%   Read the Image & its decomposition through DWT
 function [H]=img_embd(A,Wbit,L)
%%    Watermarking Algorithm implimentation
H=A;
for i=1:L
    kg=10;               %Watermark strength coefficient
    [value,location]=max(A(:));
    [R,C] = ind2sub(size(A ),find(A==value));%givies row & column of the value
    P=(ismember(A,[value]));
    G=P.*A;
    H=H+(kg*G*Wbit(i)) ;              %watermarked matrix
    V=~(ismember(A,[value]));
    A=V.*A;
end
end
