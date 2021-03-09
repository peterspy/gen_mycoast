"""
Functions to generate my own coastline.
"""
import numpy as np
import matplotlib.pyplot as plt
import shapefile
from shapely.geometry import LinearRing, Polygon

def change_map(lon_in, lat_in, mask_in, mlon_c):
    """
    change_map: a function to change input lon/mask to the lon/mask in the objective map.
    
    Usage:  lon_out, lat_out, mask_out = change_map(lon_in, lat_in, mask_in, mlon_c)

    input variables:
        lon_in: (M,), 1-D array, longitude.
        lat_in: (N,), 1-D array, latitude.
        mask_in: (N,M), 2-D array, land-sea mask. Land: 1; Sea: 0.
        mlon_c: float, center longitude of the objective map.
            e.g., 0 for [-180 180]; 180 for [0 360]; 210 for [30 390].

    output variables:
        lon_out: (M+1,), 1-D array, new map longitude and add one columm halo point.
        lat_out: (N,), 1-D array, the same as lat_in.
        mask_out: (N,M+1), 2-D array, new map mask and add one column halo point.
    """
    
    mlon_1 = mlon_c-180.0
    mlon_2 = mlon_c+180.0
    if (mlon_1>np.min(lon_in)) and (mlon_1<np.max(lon_in)):
        index_right = np.where(lon_in>=mlon_1)[0]
        index_left = np.where(lon_in<mlon_1)[0]
        
        lon_right = lon_in[index_right]
        lon_left = lon_in[index_left]+360.0
        
        lon_out = np.concatenate((lon_right, lon_left), axis=0)
        mask_out = np.concatenate((mask_in[:,index_right], mask_in[:,index_left]), axis=1)
    elif (mlon_2>np.min(lon_in)) and (mlon_2<np.max(lon_in)):
        index_right = np.where(lon_in>=mlon_2)[0]
        index_left = np.where(lon_in<mlon_2)[0]
        
        lon_right = lon_in[index_right]-360.0
        lon_left = lon_in[index_left]
        
        lon_out = np.concatenate((lon_right, lon_left), axis=0)
        mask_out = np.concatenate((mask_in[:,index_right], mask_in[:,index_left]), axis=1)
    else:
        lon_out = lon_in
        mask_out = mask_in
        
    lon_out = np.append(lon_out, lon_out[0]+360.0)
    mask_out = np.column_stack((mask_out, mask_out[:,0]))
    lat_out = lat_in
    
    return lon_out, lat_out, mask_out


def extend_map(lon_in, lat_in, mask_in):
    """
    change_map: a tricky way to treat contour line at bounds by extending input lon/lat/mask.
    
    Usage:  lon_out, lat_out, mask_out = extend_map(lon_in, lat_in, mask_in)
    
    input variables:
        lon_in: (M,), 1-D array, longitude.
        lat_in: (N,), 1-D array, latitude.
        mask_in: (N,M), 2-D array, land-sea mask. Land: 1; Sea: 0.
        
    output variables:
        lon_out: (M+2,), 1-D array, extended longitude.
        lat_out: (N,), 1-D array, the same as lat_in.
        mask_out: (N,M+2), 2-D array, extended land-sea mask. Land: 1; Sea: 0.
    """
    
    lon_1 = 2.0*lon_in[0]-lon_in[1]
    lon_2 = 2.0*lon_in[-1]-lon_in[-2]
    
    lon_out = np.insert(lon_in,0,lon_1)
    lon_out = np.append(lon_out,lon_2)
    
    lat_out = lat_in

    mask_out = np.zeros((len(lat_out),len(lon_out)))
    mask_out[:,1:-1] = mask_in
    
    # case Antarctica
    anta_lat = np.where(lat_in<-60.0);
    mask_out[anta_lat,0] = mask_in[anta_lat,0];
    mask_out[anta_lat,-1] = mask_in[anta_lat,-1];
    
    return lon_out, lat_out, mask_out


def extract_cs(lon_in, lat_in, mask_in, mlon_c=0.0, scale_thresh=1.0):
    """
    extract_cs: a function to extract my own coastline by contouring land-sea mask.
    
    Usage:  ring_list = extract_cs(lon_in, lat_in, mask_in, mlon_c=0.0, scale_thresh=1.0)
    
    input variables:
        lon_in: (M,), 1-D array, longitude.
        lat_in: (N,), 1-D array, latitude.
        mask_in: (N,M), 2-D array, land-sea mask. Land: 1; Sea: 0.
        mlon_c: float, center longitude of the objective map.
            e.g., 0 for [-180 180]; 180 for [0 360]; 210 for [30 390].
        scale_thresh: float (unit: degree), remove islands/lakes smaller than this scale.
        
    output variables:
        ring_list: list of closed rings:
            [ [(x11,y11),(x12,y12),...,(x11,y11)],
             [(x21,y21),(x22,y22),...,(x21,y21)],
             ...
             [(xm1,ym1),(xm2,ym2),...,(xm1,ym1)] ]
    """
    
    lon_c, lat_c, mask_c = change_map(lon_in, lat_in, mask_in, mlon_c)
    lon_start, lon_end, lat_anta= np.min(lon_c), np.max(lon_c), -89.9
    resolution = (lon_end-lon_start)/(len(lon_c)-1)
    
    lon_e, lat_e, mask_e = extend_map(lon_c, lat_c, mask_c)
    
    fig, ax = plt.subplots(1,1,figsize=(16,8))
    cs = ax.contour(lon_e, lat_e, mask_e, levels=[0.5])
    ax.set_xlim([lon_start-10, lon_end+10])
    ax.set_ylim([-100, 100])

    
    ring_list = []
    for i in range(len(cs.allsegs[0])):
        coast_segment = cs.allsegs[0][i]
        x = coast_segment[:,0]
        y = coast_segment[:,1]
        
        # remove small islands and lakes
        if (len(x) < 4*scale_thresh/resolution):
            continue
        
        if (x[0]!=x[-1] and y[0]==y[-1]):
            # CASE: Antarctica
            x = np.append(x,[x[-1],x[0],x[0]])
            y = np.append(y,[lat_anta,lat_anta,y[0]])
            msg_str = 'start/end point lon cyclic: [%7.2f,%7.2f]. start point: (%7.2f,%7.2f). end point: (%7.2f,%7.2f). \n'
            print(msg_str %(lon_start,lon_end,x[0],y[0],x[-1],y[-1]))
            
        elif (y[0]!=y[-1]): 
            # ERROR: Polygon needs to be a circle
            msg_str = 'start/end point not closed: [%7.2f,%7.2f]. start point: (%7.2f,%7.2f). end point: (%7.2f,%7.2f). \n'
            print(msg_str %(lon_start,lon_end,x[0],y[0],x[-1],y[-1]))
            
        x[x<lon_start] = lon_start
        x[x>lon_end] = lon_end

        ring_i = np.column_stack((x, y))
        ring_list.append(ring_i.tolist())
        
    return ring_list


def sort_ring_byarea(ring_list, descend=True):
    """
    sort_ring_byarea: a function to sort all rings (polygon bounds) by their polygon areas.
        Large rings are more likely to be outer bounds (continent), while small rings inner bounds (lake).
        
    Usage:  ring_sorted, area_sorted = sort_ring_byarea(ring_list, descend=True)
    
    input variables:
        ring_list: list of closed rings:
            [ [(x11,y11),(x12,y12),...,(x11,y11)],
             [(x21,y21),(x22,y22),...,(x21,y21)],
             ...
             [(xm1,ym1),(xm2,ym2),...,(xm1,ym1)] ]
        descend: True, sort area from large to small; False, sort area from small to large.
    
    output variables:
        ring_sorted: list of rings.
        area_sorted: list of areas.
    """
    
    area, ring_sorted = [], []
    
    for i in range(len(ring_list)):
        poly_i = Polygon(ring_list[i])
        area.append(poly_i.area)
        
    area_index = sorted(range(len(area)), key=lambda k: area[k], reverse=descend)
    
    for i in range(len(ring_list)):
        ring_sorted.append(ring_list[area_index[i]])
        
    area_sorted = sorted(area, reverse=descend)
    
    return ring_sorted, area_sorted


def sort_ring_bypoly(ring_list):
    """
    sort_ring_bypoly: a function to sort all rings by polygon relation.
        To check if a ring is an outer(exterior) bound or inner(interior) bound,
        and to sort all rings as: [outer1,inners1,outer2,inners2, ... ,outerM,innersM].
        
    Algorithm:
        compare polygonA and polygonB on a map,
            1: polygonA conatains polygonB
            2: polygonA within polygonB
            3: polygons are independent
        Once you find polygonA conatains polygonB, polygonA/polygonB is determined to be an outer/inner bound.
        
    Usage:  ring_sorted, area_sorted, mark_sorted = sort_ring_bypoly(ring_list)
        
    input variables:
        ring_list: list of closed rings:
            [ [(x11,y11),(x12,y12),...,(x11,y11)],
             [(x21,y21),(x22,y22),...,(x21,y21)],
             ...
             [(xm1,ym1),(xm2,ym2),...,(xm1,ym1)] ]
         
    output variables:
        ring_sorted: list of rings.
        area_sorted: list of areas. Positive: polygons; Negative: holes.
        mark_sorted: list of marks. 'Land'; 'Lake'; 'Antarctica'.
    """
    
    ring_listin = ring_list.copy()
    ring_sorted, area_sorted, mark_sorted = [], [], []
    
    while len(ring_listin)>0:
        is_ext = 1
        int_index = []
        
        poly_ext = Polygon(ring_listin[0])
        for i in range(1,len(ring_listin)):
            poly_int = Polygon(ring_listin[i])
            if poly_ext.contains(poly_int):
                int_index.append(i)
            elif poly_ext.within(poly_int):
                ring_listin[0], ring_listin[i] = ring_listin[i], ring_listin[0]
                is_ext = 0
                break
                
        if is_ext:
            # outer should be clockwise
            ring_i = ring_listin[0]
            ring_is_ccw = LinearRing(ring_i).is_ccw
            if ring_is_ccw:
                ring_i.reverse()
            ring_sorted.append(ring_i)
            area_i = abs(Polygon(ring_i).area)
            area_sorted.append(area_i)
            lat_i = np.mean(np.array(ring_i)[:,1])
            if (area_i>1000.0) and (lat_i<-60.0):
                mark_sorted.append('Antarctica')
            else:
                mark_sorted.append('Land')
            
            # inners should be counter-clockwise
            for i in range(len(int_index)):
                ring_i = ring_listin[int_index[i]]
                ring_is_ccw = LinearRing(ring_i).is_ccw
                if not ring_is_ccw:
                    ring_i.reverse()
                ring_sorted.append(ring_i)
                area_i = -1.0*abs(Polygon(ring_i).area)
                area_sorted.append(area_i)
                mark_sorted.append('Lake')
                
            # del sorted list
            for i in reversed(int_index):
                del ring_listin[i]
            del ring_listin[0]

    return ring_sorted, area_sorted, mark_sorted


def write_shp_Basemap(fname, ring_list, area_list, mark_list):
    """
    write_shp_Basemap: a function to write data to shapefile (for Basemap).
    
    Usage:  write_shp_Basemap(fname, ring_list, area_list, mark_list)
    
    input variables:
        fname: filename of shapefile (no filename extension)
        ring_list: list of rings.
        area_list: list of areas. Positive: polygons; Negative: holes.
        mark_list: list of marks. 'Land'; 'Lake'; 'Antarctica'.
    """
    
    w = shapefile.Writer(fname)
    w.field('Polygon', 'C')
    for i in range(len(area_list)):
        w.poly([ring_list[i]])
        w.record(mark_list[i])
    w.close()
    
    return


def write_shp_Cartopy(fname, ring_list, area_list, mark_list):
    """
    write_shp_Cartopy: a function to write data to shapefile (for Cartopy).
    
    Usage:  write_shp_Cartopy(fname, ring_list, area_list, mark_list)
    
    input variables:
        fname: filename of shapefile (no filename extension)
        ring_list: list of rings.
        area_list: list of areas. Positive: polygons; Negative: holes.
        mark_list: list of marks. 'Land'; 'Lake'; 'Antarctica'.
    """
    
    index = np.where(np.array(area_list)>0)[0]
    index = np.append(index,len(area_list))
    
    w = shapefile.Writer(fname)
    w.field('Polygon', 'C')
    
    for i in range(len(index)-1):
        i_start, i_end = index[i], index[i+1]
        w.poly(ring_list[i_start:i_end])
        w.record(mark_list[i_start])
    w.close()
    
    return

