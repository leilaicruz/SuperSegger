function locus = intTrackSpots(fluor, numLoci, celld, CONST);
% intTrackSpots : Fits locus positions from the fluorescence
% image
%
% INPUT : 
%   fluor: fluorescence image
%   numLoci: number of loci to be found, set by the segmentation contants
%   celld : is the cell file 
%   CONST : are the segmentation constants
% 
% Copyright (C) 2016 Wiggins Lab 
% University of Washington, 2016
% This file is part of SuperSeggerOpti.

opt =  optimset('MaxIter',25,'Display','off', 'TolX', 1/10);

% Does the dirty work of fitting loci
locus = compSpotPosDevFmin(double(fluor),celld.mask,numLoci,CONST,1,[],2,opt);

r=1;

% correct the position of the loci with the offset of the lower corner of
% the image.
num_spot = length(locus);
for j = 1:num_spot;
    locus(j).r = locus(j).r + celld.r_offset-[1,1];
    locus(j).shortaxis = ...
        (locus(j).r-celld.coord.rcm)*celld.coord.e2;
    locus(j).longaxis = ...
        (locus(j).r-celld.coord.rcm)*celld.coord.e1;
    
end
end