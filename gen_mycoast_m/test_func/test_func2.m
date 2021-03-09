%% some basic test 2
clear;clc;close all;
addpath('../internal_func');

%% test gen_mycoast
file_name = '../paleo_topo/I6_C.VM5a_10min.21.nc';

lon = ncread(file_name,'lon');
lat = ncread(file_name,'lat');
mask = ncread(file_name,'sftlf');

mask = 1-mask/100;

%% vars
lon_c = 180;    scale = 4.0;
file_name = '../out_shape/mycoast';  file_format = 'mat';

%% generate mycoast
[lon_seg, lat_seg] = extract_cs(lon, lat, mask, lon_c, scale);
[lon_sorted1, lat_sorted1, area_sorted1] = sort_ring_byarea(lon_seg, lat_seg);
[lon_sorted2, lat_sorted2, area_sorted2, mark_sorted2] = sort_ring_bypoly(lon_sorted1, lat_sorted1);
Data = write_shape(lon_sorted2, lat_sorted2, area_sorted2, mark_sorted2, file_name, file_format);

%% verification for my coastline
figure; axis([lon_c-190 lon_c+190 -100 100]); hold on;
if strcmp(file_format,'shp')
    for i=1:size(Data,2)
        if (Data(i).Area>0)
            patch(Data(i).X,Data(i).Y,[0.7 0.7 0.7]);
        else
            patch(Data(i).X,Data(i).Y,[0.3 0.3 0.3]);
        end
    end
elseif strcmp(file_format,'mat')
    for i=1:size(Data.Area,1)
        s_ind = Data.k(i)+1;
        e_ind = Data.k(i+1)-1;
        if (Data.Area(i)>0)
            patch(Data.ncst(s_ind:e_ind,1),Data.ncst(s_ind:e_ind,2),[0.7 0.7 0.7]);
        else
            patch(Data.ncst(s_ind:e_ind,1),Data.ncst(s_ind:e_ind,2),[0.7 0.7 0.7]);
        end
    end
end
