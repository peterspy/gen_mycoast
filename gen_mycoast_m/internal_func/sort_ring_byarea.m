function [lon_sorted, lat_sorted, area_sorted] = sort_ring_byarea(lon_in, lat_in)

% A function to sort all rings (polygon bounds) by their polygon areas.
%       Large rings are more likely to be outer bounds (continent), 
%       while small rings are more likely to be inner bounds (lake).
%
% Usage:
% [lon_sorted, lat_sorted, area_sorted] = sort_ring_byarea(lon_in, lat_in)
% 
% input variables:
% lon_in: {M,1} cell. input polygon lon.
% lat_in: {M,1} cell. input polygon lat.
% 
% output variables:
% lon_sorted: {M,1} cell. sorted polygon lon.
% lat_sorted: {M,1} cell. sorted polygon lat.
% area_sorted: [M,1] array. sorted polygon areas.

area = zeros(size(lon_in));

lon_sorted = {};
lat_sorted = {};

for i=1:size(lon_in,1)
    area(i,1) = abs(polyarea(lon_in{i},lat_in{i}));
end
[area_sorted,area_index] = sort(area,'descend');

for i=1:size(lon_in,1)
    lon_sorted{end+1,1} = lon_in{area_index(i)};
    lat_sorted{end+1,1} = lat_in{area_index(i)};
end

return
end