% Andrew Parlier
% decimated data from APEX-epsi investigation
% May 2022

%% load data and set paths
clear all
close all
clc
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
data = load('processed_data\decimated\SOM_APEX_22_05_24_203844.mat');
apf = data.apf;
clear data;

%% plot spectra
fs = 160;
nfft = 2048;
df = 160/(2*nfft);
f = df:df:fs/2;
f = f(1:256);
w = apf.dpdt;
for i = 1:length(w)
    k(i, :) = f./w(i);
end
figure;
loglog(k', apf.avg_shear_k', 'LineWidth',2)
set(gca, 'FontSize',14, 'XScale','log')
xlabel('wavenumber (cpm)')
ylabel('\Phi_{shear} (s^{-2}/cpm)')
title('shear spectra')

%% calc epsilon and plot
kvis = 1.5e-6;
kmax = 100;
for i = 1:length(apf.epsilon)
    [eps_dec(i), kc_dec(i)] = eps1_mmp(k(i, :), apf.avg_shear_k(i, :), kvis, kmax);
end
figure
plot(apf.epsilon, apf.pressure, 'LineWidth',2);
hold on
plot(eps_dec, apf.pressure, 'LineWidth',2);
plot(abs(apf.epsilon - eps_dec), apf.pressure, 'LineWidth',2);
legend('onboard', 'decimated', 'difference')
set(gca, 'YDir', 'reverse')
xlabel('\epsilon (W/kg)')
ylabel('depth(m)')
title(sprintf('\\nu = %.2g m^2/s', kvis))
set(gca, 'FontSize',14, 'XScale','log')

%%
figure
ratio = eps_dec./apf.epsilon;
plot(ratio, apf.pressure, 'LineWidth',2);