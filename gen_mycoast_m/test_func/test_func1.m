%% some basic test 1
clear;clc;close all;
addpath('../internal_func')

%% read file
file_name = '../paleo_topo/I6_C.VM5a_10min.21.nc';

lon = ncread(file_name,'lon');
lat = ncread(file_name,'lat');
mask = ncread(file_name,'sftlf');

mask = 1-mask/100;
figure;pcolor(lon,lat,mask');shading flat;

%% vars
lon_in = lon;
lat_in = lat;
mask_in = mask;
mlon_c = 210;

%% test change_map
[lon_out1, lat_out1, mask_out1] = change_map(lon_in, lat_in, mask_in, mlon_c);
figure;pcolor(lon_out1,lat_out1,mask_out1');shading flat;

%% test extend_map
[lon_out2, lat_out2, mask_out2] = extend_map(lon_out1, lat_out1, mask_out1);
figure;pcolor(lon_out2,lat_out2,mask_out2');shading flat;

