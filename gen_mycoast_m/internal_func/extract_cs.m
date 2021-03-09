function [lon_out, lat_out] = extract_cs(lon_in, lat_in, mask_in, mlon_c, scale_thresh)

% A function to extract contour segmens of land-sea mask.
% 
% Usage:
% [lon_out, lat_out] = extract_cs(lon_in, lat_in, mask_in, mlon_c, scale_thresh)
% 
% input variables:
% lon_in: [M 1], 1-D longitude array.
% lat_in: [N 1], 1-D latitude array.
% mask_in: [M N], 2-D land-sea mask matrix. Sea: 1; Land: 0.
% mlon_c: [1 1], center longitude of the objective map.
%     e.g., 0 for [-180 180]; 180 for [0 360]; 170-180 is suggested for north pole projection.
% scale_thresh: [1 1], remove islands/lakes smaller than this scale. (unit: degree)
% 
% output variables:
% lon_out: {M,1} cell. contour segment lons.
% lat_out: {M,1} cell. contour segment lats.

% change map
[lon1, lat1, mask1] = change_map(lon_in, lat_in, mask_in, mlon_c);
lon_start = min(lon1); lon_end = max(lon1); lat_anta = -89.9;
resolution = (lon_end-lon_start)/(size(lon1,1)-1);

[lon, lat, mask] = extend_map(lon1, lat1, mask1);
[lat,lon] = meshgrid(lat,lon);
mask = mask*1000;

% get contour
figure;
[coast,~] = contour(lon,lat,mask,[500,500]);
coast=[coast,[500;0]];
coast(:,(coast(1,:)==500))=nan;

index = find(isnan(coast(1,:)));
lon_out={}; lat_out={};
for i = 1:length(index)-1
    coast_segment = coast(:,index(i)+1:(index(i+1)-1));
    x = coast_segment(1,:);
    y = coast_segment(2,:);
    
    if (size(x,2) < 4*(scale_thresh/resolution))
        continue
    end
    
    if (x(1)~=x(end) && y(1)==y(end))
        % CASE: Antarctica
        x = [x,x(end),x(1),x(1)];
        y = [y,lat_anta,lat_anta,y(1)];
        fprintf('start/end point lon cyclic: [%7.2f,%7.2f] ',lon_start,lon_end);
        fprintf('start point: (%7.2f,%7.2f) ',x(1),y(1));
        fprintf('end point: (%7.2f,%7.2f)\n',x(end),y(end));
    elseif (y(1)~=y(end))
        % ERROR: Polygon needs to be a circle
        fprintf('start/end point not closed: [%7.2f,%7.2f] ',lon_start,lon_end);
        fprintf('start point: (%7.2f,%7.2f) ',x(1),y(1));
        fprintf('end point: (%7.2f,%7.2f)\n',x(end),y(end));
        continue
    end
    
    x(x<lon_start) = lon_start;
    x(x>lon_end) = lon_end;
    
    lon_out{end+1,1} = x;
    lat_out{end+1,1} = y;
end

return
end