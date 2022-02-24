% Andrew Parlier
% APEX-epsi initial test profiles
% Feb 2022

%%
% open APEX .edf profiles and import data
fid = fopen('profiles\19846.001.edf');
data = textscan(fid, '%7.2f %7.4f %7.4f %7.4f %7.4f %5.1f %4u', 'HeaderLines', 92);