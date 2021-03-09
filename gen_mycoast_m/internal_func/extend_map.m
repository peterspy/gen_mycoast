function [lon_out, lat_out, mask_out] = extend_map(lon_in, lat_in, mask_in)

% A tricky way to treat contour line at bounds by extending input lon/lat/mask.
% 
% Usage:
% [lon_out, lat_out, mask_out] = extend_map(lon_in, lat_in, mask_in)
% 
% input variables:
% lon_in: [M 1], 1-D longitude array.
% lat_in: [N 1], 1-D latitude array.
% mask_in: [M N], 2-D land-sea mask matrix. Sea: 1; Land: 0.
% 
% output variables:
% lon_out: [M+2 1], 1-D extended longitude array.
% lat_out: [N 1], 1-D latitude array. The same as lat_in.
% mask_out: [M+2 N], 2-D extended land-sea mask matrix. Sea: 1; Land: 0.

lon_1 = 2.0*lon_in(1)-lon_in(2);
lon_2 = 2.0*lon_in(end)-lon_in(end-1);

lon_out = [lon_1;lon_in;lon_2];
lat_out = lat_in;

mask_out = ones([size(lon_out,1),size(lat_out,1)]);
mask_out(2:end-1,:) = mask_in;

% case Antarctica
anta_lat = find(lat_in<-60.0);
mask_out(1,anta_lat) = mask_in(1,anta_lat);
mask_out(end,anta_lat) = mask_in(end,anta_lat);

return
end