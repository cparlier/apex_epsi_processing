% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% March 2022

%% load appropriate data and change paths as needed
clear all
addpath(genpath('C:\Users\cappa\Documents\EPSILOMETER'));
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
data = load('processed_data\nfft4096\Profile007.mat');
profile(1) = data.Profile;
data = load('processed_data\nfft4096\Profile008.mat');
profile(2) = data.Profile;
data = load('processed_data\nfft4096\Profile009.mat');
profile(3) = data.Profile;
data = load('processed_data\nfft4096\Profile010.mat');
profile(4) = data.Profile;
clear data

%% subplot with all chi profiles MUST USE 4096 FOR THESE
figure(3)
clf
width = 1/length(profile) - 0.025;
height = 0.725;
for i = 1:length(profile)
%     mask = profile(i).epsilon(:, 2) > 1e-11;
    ax(i) = subplot('Position', [(i - 1)*width + 0.065, .1, width, height]);
    semilogx(profile(i).chi(:, 2), profile(i).z(:));
    if i ~= 1
        set(gca, 'YTick', [])
    end
    set(gca, 'YDir', 'reverse')
    ax(i).XTick = [10^-10 10^-6];
    xlabel('\chi (K^2/s)')
    title(sprintf('Profile %d', 6 + i))
end
linkaxes(ax(1:end), 'xy');
ylabel(ax(1), 'Depth(m)')
ax(1).YLim = [0 730];
% ax(1).XLim = [10^-10 10^-5];
sgtitle({'Standalone APEX-epsi', '\chi across all standard ascent profiles'})

figure(4)
clf
for i = 1:length(profile)
    mask = profile(i).chi(:, 2) > 0;
    line(i) = semilogx(profile(i).chi(:, 2), profile(i).z(:));
    hold on
    min_chi = profile(i).chi(mask, 2);
    [profile(i).min_chi.val, profile(i).min_chi.idx] = min(min_chi);
    color = get(line(i), 'Color');
    xline(profile(i).min_chi.val, 'Color',color, 'LineStyle','--')
end
hold off
set(gca, 'YDir', 'reverse')
% xlim([10^-10 10^-5])
% ylim([100 150])
xlabel('\chi (K^2/s)')
ylabel('Depth (m)')
title({'Standalone APEX-epsi', '\chi across all standard ascent profiles'})
legend('Profile 7', 'lowest \chi measured', 'Profile 8', 'lowest \chi measured',...
    'Profile 9', 'lowest \chi measured', 'Profile 10',...
    'lowest \chi measured', 'Location', 'east')

%%
for i = 1:length(profile)
    profile(i).Meta_Data.paths.process_library = 'C:\Users\cappa\Documents\EPSILOMETER';
    profile(i).Meta_Data.paths.calibration = 'C:\Users\cappa\Documents\EPSILOMETER\CALIBRATION\ELECTRONICS';
    profile(i).Meta_Data.paths.profiles = 'C:\Users\cappa\Documents\local_code\apex_epsi_processing\processed_data\nfft4096';
end
%% calculate turbulence


%% calculate and plot a number of noise floors for different rise rates
w = [0.05, 0.075, 0.1, 0.15, 0.2, 0.5, 1];
phi_v_f = 10^-10*ones(1, length(profile(1).f));
k = linspace(1, 10^3, length(phi_v_f));
phi_shear_k = nan(length(w), length(k));
for i = 1:length(w)
    phi_shear_k(i, :) = phi_v_f.*w(i).*k.^2;
end
loglog(k, phi_shear_k)
legend('5', '7.5', '10', '15', '20', '50', '100')
epsilon = [1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5];
for i = 1:length(epsilon)
    [k, Pxx] = panchev(epsilon(i), 1.5e-6);
    hold on
    loglog(k, Pxx)
end
hold off
