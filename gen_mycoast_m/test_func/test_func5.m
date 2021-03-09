%% plot lon_c & scale
clear;clc;close all;
addpath('../internal_func')
addpath(genpath('C:\Program Files\MATLAB\R2019b\toolbox\m_map'));

%% topo mask
file_name = '../paleo_topo/I6_C.VM5a_10min.21.nc';

lon = ncread(file_name,'lon');
lat = ncread(file_name,'lat');
mask = ncread(file_name,'sftlf');

mask = 1-mask/100;

%% generate mycoast1
lon_c1 = 0;    scale1 = 4.0;
[lon_seg, lat_seg] = extract_cs(lon, lat, mask, lon_c1, scale1);
[lon_sorted1, lat_sorted1, area_sorted1] = sort_ring_byarea(lon_seg, lat_seg);
[lon_out1, lat_out1, area_out1, mark_out1] = sort_ring_bypoly(lon_sorted1, lat_sorted1);

%% generate mycoast2
lon_c2 = 180;    scale2 = 4.0;
[lon_seg, lat_seg] = extract_cs(lon, lat, mask, lon_c2, scale2);
[lon_sorted1, lat_sorted1, area_sorted1] = sort_ring_byarea(lon_seg, lat_seg);
[lon_out2, lat_out2, area_out2, mark_out2] = sort_ring_bypoly(lon_sorted1, lat_sorted1);

%% generate mycoast3
lon_c3 = 0;    scale3 = 1.0;
[lon_seg, lat_seg] = extract_cs(lon, lat, mask, lon_c3, scale3);
[lon_sorted1, lat_sorted1, area_sorted1] = sort_ring_byarea(lon_seg, lat_seg);
[lon_out3, lat_out3, area_out3, mark_out3] = sort_ring_bypoly(lon_sorted1, lat_sorted1);

%% generate mycoast4
lon_c4 = 180;    scale4 = 1.0;
[lon_seg, lat_seg] = extract_cs(lon, lat, mask, lon_c4, scale4);
[lon_sorted1, lat_sorted1, area_sorted1] = sort_ring_byarea(lon_seg, lat_seg);
[lon_out4, lat_out4, area_out4, mark_out4] = sort_ring_bypoly(lon_sorted1, lat_sorted1);

%%
figure; hold on;

subplot(2,2,1);hold on
m_proj('miller','lon',[lon_c1-180 lon_c1+180],'lat',[-90 90]);
for i=1:size(area_out1,1)
    if (area_out1{i}>0)
        m_patch(lon_out1{i},lat_out1{i},[0.7 0.7 0.7]);
    else
        m_patch(lon_out1{i},lat_out1{i},[0.3 0.3 0.3]);
    end
end
m_grid;
title_str1 = ['lonc=',num2str(lon_c1),';scale=',num2str(scale1)];
title(title_str1);

subplot(2,2,2);
m_proj('miller','lon',[lon_c2-180 lon_c2+180],'lat',[-90 90]);
for i=1:size(area_out2,1)
    if (area_out2{i}>0)
        m_patch(lon_out2{i},lat_out2{i},[0.7 0.7 0.7]);
    else
        m_patch(lon_out2{i},lat_out2{i},[0.3 0.3 0.3]);
    end
end
m_grid;
title_str2 = ['lonc=',num2str(lon_c2),';scale=',num2str(scale2)];
title(title_str2);

subplot(2,2,3);
m_proj('miller','lon',[lon_c3-180 lon_c3+180],'lat',[-90 90]);
for i=1:size(area_out3,1)
    if (area_out3{i}>0)
        m_patch(lon_out3{i},lat_out3{i},[0.7 0.7 0.7]);
    else
        m_patch(lon_out3{i},lat_out3{i},[0.3 0.3 0.3]);
    end
end
m_grid;
title_str3 = ['lonc=',num2str(lon_c3),';scale=',num2str(scale3)];
title(title_str3);

subplot(2,2,4);
m_proj('miller','lon',[lon_c4-180 lon_c4+180],'lat',[-90 90]);
for i=1:size(area_out4,1)
    if (area_out4{i}>0)
        m_patch(lon_out4{i},lat_out4{i},[0.7 0.7 0.7]);
    else
        m_patch(lon_out4{i},lat_out4{i},[0.3 0.3 0.3]);
    end
end
m_grid;
title_str4 = ['lonc=',num2str(lon_c4),';scale=',num2str(scale4)];
title(title_str4);

%%
saveas(gcf,'../out_figure/lonc_and_scale.png','png');
