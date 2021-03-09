%% example for plotting map
clear;clc;close all;
addpath('../internal_func')
addpath(genpath('C:\Program Files\MATLAB\R2019b\toolbox\m_map'));

%% vars
lon_c = 180;
mat_fname =  '../out_shape/mycoast.mat';
shp_fname =  '../out_shape/mycoast';

%% global map case 1
figure;
m_proj('miller','lon',[lon_c-180 lon_c+180],'lat',[-90 90]);
m_usercoast(mat_fname,'patch',[.7 .7 .7])
m_grid;

%% global map case 2
figure; hold on;

m_proj('miller','lon',[lon_c-180 lon_c+180],'lat',[-90 90]);
M = m_shaperead(shp_fname);

for i = 1:length(M.ncst)
    lon = M.ncst{i}(:,1);
    lat = M.ncst{i}(:,2);
    if M.dbf.Area{i}>0
        m_patch(lon,lat,[0.7 0.7 0.7]);
    else
        m_patch(lon,lat,'w');
    end
end

m_grid;

%% Antarctic case 1
figure; hold on;

m_proj('azimuthal equal-area','latitude',-90,'radius',40,'rectbox','on');
load(mat_fname);

for i = 1:size(Area,1)
    lon = ncst((k(i)+1):(k(i+1)-1),1);
    lat = ncst((k(i)+1):(k(i+1)-1),2);
    if (Area(i)>0)
        if (mean(lat)<-60.0 && Area(i)>1000.0)
            lon_anta = lon(lat>-89.0);
            lat_anta = lat(lat>-89.0);
            [x_anta,y_anta] = m_ll2xy(lon_anta,lat_anta);
            patch(x_anta,y_anta,[0.7 0.7 0.7]);
        else
            m_patch(lon,lat,[0.7 0.7 0.7]);
        end
    else
        m_patch(lon,lat,'w');
    end
end

m_grid;

%% Antarctic case 2
figure; hold on;

m_proj('azimuthal equal-area','latitude',-90,'radius',40,'rectbox','on');
M = m_shaperead(shp_fname); 

for i=1:length(M.ncst)
    lon = M.ncst{i}(:,1);
    lat = M.ncst{i}(:,2);
    if M.dbf.Area{i}>0
        if strcmp(M.dbf.Name{i},'Antarctica')
            lon_anta = lon(lat>-89.0);
            lat_anta = lat(lat>-89.0);
            [x_anta,y_anta] = m_ll2xy(lon_anta,lat_anta);
            patch(x_anta,y_anta,[0.7 0.7 0.7]);
        else
            m_patch(lon,lat,[0.7 0.7 0.7]);
        end
    else
        m_patch(lon,lat,'w');
    end
end

m_grid;
