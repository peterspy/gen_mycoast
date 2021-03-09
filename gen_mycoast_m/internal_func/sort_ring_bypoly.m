function [lon_sorted, lat_sorted, area_sorted, mark_sorted] = sort_ring_bypoly(lon_in, lat_in)

% A function to sort all rings by polygon relation.
%   To check if a ring is an outer(exterior) bound or inner(interior) bound,
%   and to sort all rings as: {outer1,inners1,outer2,inners2, ... ,outerM,innersM}.
%
% Algorithm:
%   compare polygonA and polygonB on a map,
%       1: polygonA conatains polygonB
%       2: polygonA within polygonB
%       3: polygons are independent
%   Once you find polygonA conatains polygonB, polygonA/polygonB is determined to be an outer/inner bound.
%
% Usage:
% [lon_sorted, lat_sorted, area_sorted, mark_sorted] = sort_ring_bypoly(lon_in, lat_in)
% 
% input variables:
% lon_in: {M,1} cell. input polygon lon.
% lat_in: {M,1} cell. input polygon lat.
% 
% output variables:
% lon_sorted: {M,1} cell. sorted polygon lon.
% lat_sorted: {M,1} cell. sorted polygon lat.
% area_sorted: {M,1} cell. sorted polygon areas. Positive: polygons; Negative: holes.
% mark_sorted: {M,1} cell. sorted polygon marks. 'Land'; 'Lake'; 'Antarctica'.

index_list = 1:size(lon_in,1);

lon_sorted = {};
lat_sorted = {};
area_sorted = {};
mark_sorted = {};

while size(index_list,2)>0
    lon_ext = lon_in{index_list(1)};
    lat_ext = lat_in{index_list(1)};
    int_index = [];
    is_ext = 1;
    for i=2:size(index_list,2)
        lon_int = lon_in{index_list(i)};
        lat_int = lat_in{index_list(i)};
        in_res1 = inpolygon(lon_int,lat_int,lon_ext,lat_ext);
        in_res2 = inpolygon(lon_ext,lat_ext,lon_int,lat_int);
        if all(in_res1)
            int_index = [int_index,index_list(i)];
        elseif all(in_res2)
            a = index_list(1);
            index_list(1) = index_list(i);
            index_list(i) = a;
            is_ext = 0;
            break
        end
    end
    
    if is_ext
        % outer should be clockwise
        if ~ispolycw(lon_ext,lat_ext)
            lon_ext = flip(lon_ext);
            lat_ext = flip(lat_ext);
        end
        area_i = abs(polyarea(lon_ext,lat_ext));
        mark_i = 'Land';
        if (area_i>1000.0) && (mean(lat_ext)<-60.0)
            mark_i = 'Antarctica';
        end
        area_sorted{end+1,1} = area_i;
        mark_sorted{end+1,1} = mark_i;
        lon_sorted{end+1,1} = lon_ext;
        lat_sorted{end+1,1} = lat_ext;
        
        % inners should be counter-clockwise
        for i=1:size(int_index,2)
            lon_int = lon_in{int_index(i)};
            lat_int = lat_in{int_index(i)};
            if ispolycw(lon_int,lat_int)
                lon_int = flip(lon_int);
                lat_int = flip(lat_int);
            end
            area_i = -abs(polyarea(lon_int,lat_int));
            mark_i = 'Lake';
            area_sorted{end+1,1} = area_i;
            mark_sorted{end+1,1} = mark_i;
            lon_sorted{end+1,1} = lon_int;
            lat_sorted{end+1,1} = lat_int;
        end
        index_list = setdiff(index_list(2:end),int_index);
    end
end

return
end
