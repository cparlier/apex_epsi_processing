% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% April 2022

%% load appropriate data and change paths as needed
clear all
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
load('processed_data\downsampled\profiles_nfft2048.mat');

%% set correct dTdV and reprocess data to get correct chi
for i = 1:length(profile)
    profile(i).Meta_Data.AFE.t2.cal = 34.1;
    profile(i) = mod_epsilometer_calc_turbulence_v2(profile(i).Meta_Data, profile(i));
end

%% plots of raw acceleration
for i = 1:length(profile)
    z_epsi = interp1(1:length(profile(i).ctd.z), profile(i).ctd.z, linspace(1, length(profile(i).ctd.z), length(profile(i).epsi.s2_volt)));
    figure
    ax(i, 1) = subplot(1, 4, 1);
    plot(profile(i).epsi.s2_volt, z_epsi)
    ylabel('depth (m)')
    title('shear (V)')
    ax(i, 2) = subplot(1, 4, 2);
    plot(profile(i).epsi.a1_g - mean(profile(i).epsi.a1_g), z_epsi)
    title('a1 anomaly (g)')
    ax(i, 3) = subplot(1, 4, 3);
    plot(profile(i).epsi.a2_g - mean(profile(i).epsi.a2_g), z_epsi)
    title('a2 anomaly (g)')
    ax(i, 4) = subplot(1, 4, 4);
    plot(profile(i).epsi.a3_g - mean(profile(i).epsi.a3_g), z_epsi)
    title('a3 anomaly (g)')
    linkaxes(ax(i, :), 'y')
    linkaxes(ax(i, 2:4), 'x')
    set(ax(i, 4), 'XLim', [-.01 .01])
    set(ax(i, :), 'YDir', 'reverse')
    sgtitle({'Standalone APEX-epsi', sprintf('Profile %d', profile(i).profNum)}, 'FontSize',16)
end

%% plot a3 in a period where buoyancy pump goes on and off
% seems pretty clear that the pump is operating near 50 Hz
% integrate a3 from 40 to 65 perhaps as a cutoff?
idx = 1300:1400;
figure
clf
hold on
for i = 1:length(idx)
    loglog(profile(1).f, profile(1).Pa_g_f.a3(idx(i), :));
end
set(gca, 'YScale', 'log', 'XScale', 'log')
% ylim([10^-12 10^-4])

%% let's test it; for each profile, for each bin, integrate a3 spectrum
% between 40 and 65 Hz and plot next to the raw a3
% cutoff is 2e-6 conservatively!
close all
for i = 1:length(profile)
    profile(i).pump_check = nan(profile(i).nbscan, 1);
    for j = 1:profile(i).nbscan
        mask = (profile(i).f > 40 & profile(i).f < 65);
        profile(i).pump_check(j) = sum(profile(i).f(2)*profile(i).Pa_g_f.a3(j, mask));
    end
    z_epsi = interp1(1:length(profile(i).ctd.z), profile(i).ctd.z, linspace(1, length(profile(i).ctd.z), length(profile(i).epsi.s2_volt)));
    figure
    ax(i, 1) = subplot(1, 2, 1);
    plot(profile(i).epsi.a3_g, z_epsi)
    ylabel('depth (m)')
    title('a3 (g)')
    ax(i, 2) = subplot(1, 2, 2);
    plot(profile(i).pump_check, profile(i).z)
    title('pump check (g^2)');
    xlim([5e-7 2e-5]);
    linkaxes(ax(i, :), 'y')
    set(ax(i, 1:2), 'YDir', 'reverse')
    sgtitle({'Standalone APEX-epsi', sprintf('Profile %d', profile(i).profNum)})
end

%% remove buyoancy pump periods
threshold = 2e-6;
profile = remove_bouyancy_pump(profile, threshold);

%% plot all epsilon and chi profiles
[fig, ax] = plot_epsilon_profiles(profile);
sgtitle({'Standalone APEX-epsi', '\epsilon across all standard ascent profiles'}, 'FontSize',20)
[fig, ax] = plot_chi_profiles(profile);
sgtitle({'Standalone APEX-epsi', '\chi across all standard ascent profiles'}, 'FontSize',20)
% [fig, ax] = plot_fom_profiles(profile);
% sgtitle({'Standalone APEX-epsi', 'FOM across all standard ascent profiles'}, 'FontSize',16)



%% plot stddev and shear
close all
targets = 665;
i = 1;
% for i = 1:length(profile)
    [~, idx(i)] = min(abs(profile(i).z - targets(i)));
    depths(i) = profile(i).z(idx(i));
    figure
    ax(1) = subplot(1, 3, 1);
    plot(profile(i).epsi.s2_volt, profile(i).epsi.dnum)
    ylabel('shear (V)')
    ax(2) = subplot(1, 3, 2);
    plot(profile(i).s2_stddev, profile(i).z)
    set(gca, 'YDir', 'reverse')
    ylim([650 665])
    ax(3) = subplot(1, 3, 3);
    semilogx(profile(i).epsilon(:, 2), profile(i).z);
    set(gca, 'YDir', 'reverse')
    ylim([650 665])
% end

%% compute acceleration coherence with raw shear for all scans
num_scans = 10;
for i = 1:length(profile)
    profile(i).Cs2a1_scan = nan(profile(i).nbscan, profile(i).nfft/2 + 1);
    profile(i).Cs2a2_scan = nan(profile(i).nbscan, profile(i).nfft/2 + 1);
    profile(i).Cs2a3_scan = nan(profile(i).nbscan, profile(i).nfft/2 + 1);
    % loop through nbscan
    for j = 1:profile(i).nbscan
        left_scans = floor((num_scans - 1)/2);
        if j <= left_scans
            left_scans = j - 1;
        end
        right_scans = num_scans - left_scans - 1;
        if (profile(i).nbscan - j) < right_scans
            right_scans = profile(i).nbscan - j;
            left_scans = num_scans - right_scans - 1;
        end
        idx = profile(i).ind_range_epsi(j + right_scans, 1):profile(i).ind_range_epsi(j - left_scans, end);
        if ~isnan(idx) & (length(idx) > profile(i).nfft)
            profile(i).Cs2a1_scan(j, :) = mscohere(profile(i).epsi.s2_volt(idx), profile(i).epsi.a1_g(idx), profile(i).nfft);
            profile(i).Cs2a2_scan(j, :) = mscohere(profile(i).epsi.s2_volt(idx), profile(i).epsi.a2_g(idx), profile(i).nfft);
            profile(i).Cs2a3_scan(j, :) = mscohere(profile(i).epsi.s2_volt(idx), profile(i).epsi.a3_g(idx), profile(i).nfft);
        end
    end
end

%% show some plots
close all
targets = 370;
[fig, ax] = plot_allshear_target_depths(profile(1), targets);
[fig, ax] = plot_accelcohere_target_depths(profile(1), targets);
text(2, 0.9, sprintf('%d scan average', num_scans))

% %% add standard deviation of shear to profiles
% for i = 1:length(profile)
%     profile(i).s2_stddev = nan(profile(i).nbscan, 1);
%     for j = 1:profile(i).nbscan
%         idx = profile(i).ind_range_epsi(j, 1):profile(i).ind_range_epsi(j, end);
%         if ~isnan(idx)
%             profile(i).s2_stddev(j) = std(profile(i).epsi.s2_volt(idx));
%         end
%     end
% end

% %% plot freq spectra to scope if buoyancy pump freq is clear
% idx = 1315:1324;
% figure
% clf
% hold on
% for i = 1:length(idx)
%     loglog(profile(1).f, profile(1).Ps_volt_f.s2(idx(i), :));
% end
% set(gca, 'YScale', 'log', 'XScale', 'log')
% ylim([10^-12 10^-4])
