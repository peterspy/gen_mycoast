%% example for plotting map with lgm sst
clear;clc;close all;
addpath('../internal_func')
addpath(genpath('C:\Program Files\MATLAB\R2019b\toolbox\m_map'));

%% vars
fmesh_fname = '../lgm_xshi/fesom.mesh.diag.nc';
fdata_fname = '../lgm_xshi/sst.fesom.5500.nc';
shape_fname = '../out_shape/mycoast.mat';
lon_c = 180.0;

%% deal with tri mesh
elem = ncread(fmesh_fname,'elem');
nodes = ncread(fmesh_fname,'nodes');
sst = ncread(fdata_fname,'sst',[1 1],[Inf 1]);

lon_s = lon_c-180.0; lon_e = lon_c+180.0;

lon = nodes(:,1)*180/pi; 
lat = nodes(:,2)*180/pi;
lon(lon<lon_s) = lon(lon<lon_s)+360;

lon_elem = lon(elem);
lat_elem = lat(elem);

cycl_ind = find((max(lon_elem,[],2)-min(lon_elem,[],2))>180.0);
lon_cind1 = lon_elem(cycl_ind,:);
lon_cind1(lon_cind1<lon_c) = lon_cind1(lon_cind1<lon_c)+360.0;
lon_cind2 = lon_cind1-360.0;

xc = lon_elem;
xc(cycl_ind,:) = lon_cind1;
xc = [xc;lon_cind2];
yc = lat_elem;
yc = [yc;lat_elem(cycl_ind,:)];

elem_cycl = [elem;elem(cycl_ind,:)];
SST = mean(sst(elem_cycl),2);

%% global map sst
figure;hold on

m_proj('miller','lon',[lon_s lon_e],'lat',[-90 90]);

[XC,YC] = m_ll2xy(xc,yc);
pp = patch(XC',YC',SST);
set(pp,'EdgeColor','none');

m_usercoast(shape_fname,'patch',[.7 .7 .7],'LineWidth',1);
m_grid;

%%
saveas(gcf,'../out_figure/lgm_sst.png','png');
