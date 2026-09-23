% Make figures of Sentinel-3 OLCI Data
% Using spatially subset data 
% Data were subset using script "Spatially_Subset_Sentinel3OLCI_for_NC.m"
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
% COSURP 2026-2027 project with Miriam and Jessie

clear;
close all;
clc; % clears our command window

% We will need "Calgae2" colormap for Chlorophyll-a:
load('Calgae2.mat')

% Spatially subset to Cape Fear River and SW area
% Define coordinate bounds
n = 34.5;
w = -79.35;
e = -77.15;
s = 33;

% Name the netCDF file to quickly load variables from it. 
%%%% CHANGE TO MATCH YOUR DIRECTORY! %%%%%%%%%%%%%%%%%%%%%
datafolder = '/Users/jsturner/Documents/Project_NC_WQ/DATA/';
addpath(datafolder);
% filechl = 'chl_oc4me.nc'; % Chlorophyll a for global ocean / offshore
filechl = 'subset_20250819_S3B_chl_nn.nc'; % Chlorophyll a better for coastal waters
filetsm = 'subset_20250819_S3B_tsm_nn.nc';
imagedate = filechl(8:15); % string to use in figure title and saved figure name
if contains(filechl, 'A'), sat = 'A'; elseif contains(filechl, 'B'), sat = 'B'; end

lon = ncread([datafolder filechl],'longitude');
lat = ncread([datafolder filechl],'latitude');
% chl = ncread([datafolder filechl],'CHL_OC4ME'); % Chlorophyll a for global ocean / offshore
chl = ncread([datafolder filechl],'CHL_NN'); % Chlorophyll a better for coastal waters
tsm = ncread([datafolder filetsm],'TSM_NN'); % Total suspended matter better for coastal waters

% Check data to see if need to cut off values at a certain sanity threshold
% For example, TSM of > 50 or so is not realistic for this example
% figure;
% histogram(tsm);
tsm(tsm>50)=nan;

% Maps
% figure(1);
% clf;
% pcolor(lon,lat,chl); shading flat;
% axis([w e s n]); % Order: West, East, South, North
% % improve color range
% colormap(Calgae2);
% clim([0.1 20]);
% cb = colorbar;
% cb.Ticks = [0.25 0.5 0.75 1 1.5 2 3 5 10];
% cb.FontSize = 14;
% cb.Label.String = 'Chl-a (mg m^{-3}) (NN)';
% cb.Label.FontSize = 18;
% set(gca,'colorscale','log','xtick',[],'ytick',[])
% title([imagedate ' Sentinel-3' sat ' OLCI Chl'],'fontweight','normal','fontsize',18)
% print(gcf,[imagedate '_S3-OLCI_chl.png'],'-dpng','-r200');


figure(2);
clf;
pcolor(lon,lat,tsm); shading flat;
axis([w e s n]); % Order: West, East, South, North
% improve color range
colormap(turbo);
clim([0.1 30]);
cb = colorbar;
cb.Ticks = [0.25 0.5 0.75 1 1.5 2 6 10 20];
cb.FontSize = 14;
cb.Label.String = 'TSM (mg L^{-3})';
cb.Label.FontSize = 18;
set(gca,'colorscale','log')
title([imagedate ' Sentinel-3' sat ' OLCI TSM'],'fontweight','normal','fontsize',18)
% print(gcf,[imagedate '_S3-OLCI_tsm.png'],'-dpng','-r200');
