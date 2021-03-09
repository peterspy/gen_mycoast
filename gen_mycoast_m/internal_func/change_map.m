function [lon_out, lat_out, mask_out] = change_map(lon_in, lat_in, mask_in, mlon_c)

% A function to change input lon/mask to the lon/mask in the objective map.
% 
% Usage:
% [lon_out, lat_out, mask_out] = change_map(lon_in, lat_in, mask_in, mlon_c)
% 
% input variables:
% lon_in: [M 1], 1-D longitude array.
% lat_in: [N 1], 1-D latitude array. lat_out is not changed.
% mask_in: [M N], 2-D land-sea mask matrix. Sea: 1; Land: 0.
% mlon_c: [1 1], center longitude of the objective map.
%         e.g., 0 for [-180 180]; 180 for [0 360]; 210 for [30 390].
% 
% output variables:
% lon_out: [M+1 1],new map longitude and add one columm halo point.
% lat_out: [N 1], the same as lat_in.
% mask_out: [M+1 N], new map mask and add one column halo point.

mlon_1 = mlon_c-180;
mlon_2 = mlon_c+180;

if (mlon_1>min(lon_in)) && (mlon_1<max(lon_in))
    index_right = find(lon_in>=mlon_1);
    index_left = find(lon_in<mlon_1);
    
    lon_right = lon_in(index_right);
    lon_left = lon_in(index_left)+360;
    
    lon_out = [lon_right;lon_left];
    mask_out = [mask_in(index_right,:);mask_in(index_left,:)];
elseif (mlon_2>min(lon_in)) && (mlon_2<max(lon_in))
    index_right = find(lon_in>=mlon_2);
    index_left = find(lon_in<mlon_2);
    
    lon_right = lon_in(index_right)-360;
    lon_left = lon_in(index_left);
    
    lon_out = [lon_right;lon_left];
    mask_out = [mask_in(index_right,:);mask_in(index_left,:)];
else
    lon_out = lon_in;
    mask_out = mask_in;
end

lon_out = [lon_out;lon_out(1)+360.0];
mask_out = [mask_out;mask_out(1,:)];
lat_out = lat_in;

return
end