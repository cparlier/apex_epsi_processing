% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% March 2022

%% load appropriate data
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
%% plot all 4 profiles
figure(1)
clf
for i = 1:length(profile)
    plot(profile(i).dnum, profile(i).z)
    set(gca, 'YDir', 'reverse')
    hold on
end
hold off
datetick;
xlabel('Time')
ylabel('Depth')
title({'Standalone APEX-epsi', 'standard ascent profiles'})
legend('Profile 7', 'Profile 8', 'Profile 9', 'Profile 10')
%% subplot with all epsilon profiles
figure(1)
clf
width = 1/length(profile) - 0.025;
height = 0.725;
for i = 1:length(profile)
%     mask = profile(i).epsilon(:, 2) > 1e-11;
    ax(i) = subplot('Position', [(i - 1)*width + 0.065, .1, width, height]);
    semilogx(profile(i).epsilon(:, 2), profile(i).z(:));
    if i ~= 1
        set(gca, 'YTick', [])
    end
    set(gca, 'YDir', 'reverse')
    ax(i).XTick = [10^-10 10^-6];
    xlabel('\epsilon (W/kg)')
    title(sprintf('Profile %d', 6 + i))
end
linkaxes(ax(1:end), 'xy');
ylabel(ax(1), 'Depth(m)')
ax(1).YLim = [0 730];
ax(1).XLim = [10^-10 10^-5];
sgtitle({'Standalone APEX-epsi', '\epsilon across all standard ascent profiles'})

figure(2)
clf
for i = 1:length(profile)
    mask = profile(i).epsilon(:, 2) > 1e-11;
    line(i) = semilogx(profile(i).epsilon(:, 2), profile(i).z(:));
    hold on
    min_eps = profile(i).epsilon(mask, 2);
    [profile(i).min_eps.val, profile(i).min_eps.idx] = min(min_eps);
    color = get(line(i), 'Color');
    xline(profile(i).min_eps.val, 'Color',color, 'LineStyle','--')
end
hold off
set(gca, 'YDir', 'reverse')
xlim([10^-10 10^-5])
ylim([100 150])
xlabel('\epsilon (W/kg)')
ylabel('Depth (m)')
title({'Standalone APEX-epsi', '\epsilon across all standard ascent profiles'})
legend('Profile 7', 'lowest \epsilon measured', 'Profile 8', 'lowest \epsilon measured',...
    'Profile 9', 'lowest \epsilon measured', 'Profile 10',...
    'lowest \epsilon measured', 'Location', 'east')

%% subplot with all chi profiles
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
    xlabel('\chi (K/m^2)')
    title(sprintf('Profile %d', 6 + i))
end
linkaxes(ax(1:end), 'xy');
ylabel(ax(1), 'Depth(m)')
ax(1).YLim = [0 730];
% ax(1).XLim = [10^-10 10^-5];
sgtitle({'Standalone APEX-epsi', '\chi across all standard ascent profiles'})

figure(4)
clf
for i = 2:length(profile)
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
xlabel('\chi (K/m^2)')
ylabel('Depth (m)')
title({'Standalone APEX-epsi', '\chi across all standard ascent profiles'})
legend('Profile 7', 'lowest \chi measured', 'Profile 8', 'lowest \chi measured',...
    'Profile 9', 'lowest \chi measured', 'Profile 10',...
    'lowest \chi measured', 'Location', 'east')
%% pick some epsilons and compare for different profiles
close all
target_epsilons = [1e-10, 1e-9, 5e-9, 1e-8, 5e-8, 1e-7, 1e-6, 1e-5];
[figs, shear_spec_lines, idx] = plot_shear_panchev_target_epsilons(target_epsilons, profile);

%% overlay accleration-derived shear spectra on previous plots
[figs, accel_spec_lines, profile] = plot_add_accel_to_shear(figs, idx, profile);

%% plot available coherences for bins with above epsilons

figure;
for i = 1:length(profile)
    semilogx(profile(i).f, profile(i).Cs2a3_full);
    hold on
end
xlabel('Frequency (Hz)')
ylabel('s2 - a3 coherence')
title({'Standalone APEX-epsi', 'coherence across all standard ascent profiles'})
legend('Profile 7', 'Profile 8', 'Profile 9', 'Profile 10', 'Location','northwest')


%% work done with Matthew
% load('/Volumes/GoogleDrive/Shared drives/MOD-data-Epsilometer/epsi/SA_APEX/Cruises/Beyster2022/data/epsi/apex19846/d1/profiles/Profile004.mat')
% % Profile 7 is 
% load('/Volumes/GoogleDrive/Shared drives/MOD-data-Epsilometer/epsi/SA_APEX/Cruises/Beyster2022/data/epsi/apex19846/d1/profiles/Profile007.mat')
% %
% plot(Profile.w, Profile.pr );axis ij;shg
% %
% figure(3)
% plot(Profile.n2, Profile.pr );axis ij;shg
% %
% figure(1); semilogx(Profile.epsilon, Profile.pr );axis ij
% %
% figure(2); 
% clf
% ax=MySubplot(.1,.1,0,.1,.1,0,2,1);
% axes(ax(1))
% semilogx(Profile.epsilon, Profile.pr ,Profile.chi,Profile.pr);axis ij
% axes(ax(2))
% semilogx(Profile.t,Profile.pr );axis ij
% linkaxes(ax,'y')
% %
% semilogx(Profile.chi, Profile.pr );axis ij
% % strong: epsilon = 1e-5
% figure(4)
% wh=38;
% [kpan,Ppan]=panchev(Profile.epsilon(wh,2),Profile.kvis(wh));
% loglog(Profile.k(wh,:),Profile.Ps_shear_k.s2(wh,:),...
%     Profile.k(wh,:),Profile.Ps_shear_co_k.s2(wh,:),...
%     Profile.k(wh,:),Profile.Pa_g_f.a3(wh,:) ./ 9.8.^2 ./ abs(Profile.w(wh)),'k-',...
%     kpan,Ppan,'k--');shg
% legend('P_{sh}','P_{sh,co}','P_a / w^2')
% title([num2str(wh), ', rise rate ' abs(num2str(Profile.w(wh))) 'm/s'])
% % weaker: epsilon = 5e-8
% figure(3)
% wh=242;
% [kpan,Ppan]=panchev(Profile.epsilon(wh,2),Profile.kvis(wh));
% loglog(Profile.k(wh,:),Profile.Ps_shear_k.s2(wh,:),...
%     Profile.k(wh,:),Profile.Ps_shear_co_k.s2(wh,:),...
%     Profile.k(wh,:),Profile.Pa_g_f.a3(wh,:) ./ 9.8.^2 ./ abs(Profile.w(wh)),'k-',...
%     kpan,Ppan,'k--');shg
% legend('P_{sh}','P_{sh,co}','P_a / w^2')
% title([num2str(wh), ', rise rate ' abs(num2str(Profile.w(wh))) 'm/s'])
% % unmeasurable: 1e-11
% %We want Pa_ms2_k = Pa_g_k / g^2 = w / g^2 * Pa_g_f
% % We really want Psh_g_k = Pa_ms2_k / w^2=  Pa_g_f / g^2 / w
% figure(5)
% wh=977;
% [kpan,Ppan]=panchev(Profile.epsilon(wh,2),Profile.kvis(wh));
% loglog(Profile.k(wh,:),Profile.Ps_shear_k.s2(wh,:),...
%     Profile.k(wh,:),Profile.Ps_shear_co_k.s2(wh,:),...
%     Profile.k(wh,:),Profile.Pa_g_f.a3(wh,:) ./ 9.8.^2 ./ abs(Profile.w(wh)),'k-',...
%     kpan,Ppan,'k--');shg
% legend('P_{sh}','P_{sh,co}','P_a / w^2')
% title([num2str(wh), ', rise rate ' abs(num2str(Profile.w(wh))) 'm/s'])

