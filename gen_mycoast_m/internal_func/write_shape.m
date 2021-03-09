function Data = write_shape(lon_sorted, lat_sorted, area_sorted, mark_sorted, save_name, save_option)

% A function to write coastline shape to files.
% 
% Usage:
% Data = write_shape(lon_sorted, lat_sorted, area_sorted, mark_sorted, save_name, save_option)
% 
% input variables:
% lon_sorted: {M,1} cell. sorted polygon lon.
% lat_sorted: {M,1} cell. sorted polygon lat.
% area_sorted: {M,1} cell. sorted polygon areas. Positive: polygons; Negative: holes.
% mark_sorted: {M,1} cell. sorted polygon marks. 'Land'; 'Lake'; 'Antarctica'.
% save_name: char. save file name, no filename extension.
% save_option: char. save file format, 'mat' or 'shp'.
% 
% output variables:
% Data: struct. depend on save_option.

Data = struct([]); ncst = [nan,nan]; Area = []; Mark = mark_sorted;
for i = 1:size(area_sorted,1)
    lon = (lon_sorted{i})';
    lat = (lat_sorted{i})';
    ncst = [ncst;[lon,lat];[nan,nan]];
    Area = [Area;area_sorted{i}];
end
k = find(isnan(ncst(:,1)));

if strcmp(save_option,'mat')
    save([save_name,'.mat'],'ncst','k','Area','Mark');
    Data(1).ncst = ncst;
    Data(1).Area = Area;
    Data(1).Mark = Mark;
    Data(1).k = k;
elseif strcmp(save_option,'shp')
    for i = 1:size(k,1)-1
        i_s = k(i)+1; i_e = k(i+1)-1;
        Data(i).Geometry = 'Polygon';
        Data(i).X = ncst(i_s:i_e,1);
        Data(i).Y = ncst(i_s:i_e,2);
        Data(i).Area = Area(i);
        Data(i).Name = mark_sorted{i};
    end
    shapewrite(Data, [save_name,'.shp']);
end

return
end