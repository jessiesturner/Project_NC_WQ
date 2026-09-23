% Subset data to make Cape Fear River specific figures of Sentinel-3 OLCI Data
%
% Adapted from:
% Ocean Color Remote Sensing Part 2, University of Connecticut
% Jessie Turner, Guest Lecture/Lab 
% GEOG/MARN 3505 and 5505 -  Fall 2024, October 23, 2024
% Data source - EUMETSAT:
% https://data.eumetsat.int/data/map/EO:EUM:DAT:0407?sort=start,time,0
%
% Downloaded each granule (scene) using filters on the webpage.
% Used python script "extract_nc.py" to rename the chl and tsm files 
% in each granule with the correct date.
%
% Before plotting, use this script to subset tsm_nn.nc and chl_nn.nc files.
%
% COSURP 2026-2027 project with Miriam and Jessie

clear;
close all;
clc; % clears our command window

% Define spatial bounding box (Cape Fear River & SW Area)
n = 34.5;
w = -79.35;
e = -77.15;
s = 33;

datafolder = '/Users/jsturner/Documents/Project_NC_WQ/DATA/';

% Locate all coordinate files in data folder
coordFiles = dir(fullfile(datafolder, '*_geo_coordinates.nc'));

for k = 1:length(coordFiles)
    coordName = coordFiles(k).name;
    
    % Extract date/satellite file prefix (e.g., '20250819_S3B_')
    prefix = strrep(coordName, 'geo_coordinates.nc', '');
    
    filechl   = fullfile(datafolder, [prefix 'chl_nn.nc']);
    filetsm   = fullfile(datafolder, [prefix 'tsm_nn.nc']);
    filecoords= fullfile(datafolder, coordName);
    
    % Skip scene if missing corresponding data files
    if ~exist(filechl, 'file') || ~exist(filetsm, 'file')
        warning('Missing CHL or TSM file for prefix: %s. Skipping.', prefix);
        continue;
    end
    
    % Read spatial coordinates
    lon = ncread(filecoords, 'longitude');
    lat = ncread(filecoords, 'latitude');
    
    % Generate logical mask of pixels inside ROI
    in_bounds = (lat >= s & lat <= n & lon >= w & lon <= e);
    
    if ~any(in_bounds(:))
        fprintf('No pixels within ROI for scene %s. Skipping.\n', prefix);
        continue;
    end
    
    % Find minimum bounding rectangle in pixel grid (rows & columns)
    [rows, cols] = find(in_bounds);
    r_min = min(rows); r_max = max(rows);
    c_min = min(cols); c_max = max(cols);
    
    % Crop coordinates
    sub_lon = lon(r_min:r_max, c_min:c_max);
    sub_lat = lat(r_min:r_max, c_min:c_max);
    
    % Read log-scale data and crop to pixel bounds
    chl_log = ncread(filechl, 'CHL_NN');
    tsm_log = ncread(filetsm, 'TSM_NN');
    
    sub_chl_log = chl_log(r_min:r_max, c_min:c_max);
    sub_tsm_log = tsm_log(r_min:r_max, c_min:c_max);
    
    % Convert to linear values & apply thresholding
    sub_chl = 10.^sub_chl_log;
    sub_tsm = 10.^sub_tsm_log;
    % sub_tsm(sub_tsm > 50) = NaN;
    
    % Save subsetted CHL file
    out_chl = fullfile(datafolder, ['subset_' prefix 'chl_nn.nc']);
    save_subset_nc(out_chl, 'CHL_NN', sub_chl, sub_lat, sub_lon);
    
    % Save subsetted TSM file
    out_tsm = fullfile(datafolder, ['subset_' prefix 'tsm_nn.nc']);
    save_subset_nc(out_tsm, 'TSM_NN', sub_tsm, sub_lat, sub_lon);
    
    fprintf('Successfully processed and saved: %s\n', prefix);
end

% Local helper function to write new subsetted NetCDF file
function save_subset_nc(filename, varName, dataVar, latVar, lonVar)
    if exist(filename, 'file')
        delete(filename);
    end
    
    [dim1, dim2] = size(dataVar);
    
    % Define dimensions and write main variable
    nccreate(filename, varName, 'Dimensions', {'dim1', dim1, 'dim2', dim2}, 'Datatype', class(dataVar));
    ncwrite(filename, varName, dataVar);
    
    % Embed cropped latitude and longitude directly in output NetCDF
    nccreate(filename, 'latitude', 'Dimensions', {'dim1', dim1, 'dim2', dim2}, 'Datatype', class(latVar));
    ncwrite(filename, 'latitude', latVar);
    
    nccreate(filename, 'longitude', 'Dimensions', {'dim1', dim1, 'dim2', dim2}, 'Datatype', class(lonVar));
    ncwrite(filename, 'longitude', lonVar);
end