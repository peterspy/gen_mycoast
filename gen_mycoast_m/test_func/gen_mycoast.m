%% Main routine to gen_mycoast
clear;clc;close all;
addpath('../internal_func');

%% topo
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
