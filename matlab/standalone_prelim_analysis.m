% Andrew Parlier
% APEX-epsi processing
% epsi examination
% standalone deployment
% Feb 2022

%% generate concatenated file
addpath(genpath('C:\Users\cappa\Documents\local_code\apex_epsi_processing'));
data_dir = dir('profiles\epsi');
data = struct([]);
dnum = [];
s1_volt = [];
s2_volt = [];
t1_volt = [];
t2_volt = [];
a1_g = [];
a2_g = [];
a3_g = [];
for i = 1:length(data_dir) - 4
    temp = load(fullfile(data_dir(i + 4).name));
    data = [data, temp.epsi];
    if i == 1
        dnum = [data(i).dnum];
        s1_volt = [data(i).s1_volt];
        s2_volt = [data(i).s2_volt];
        t1_volt = [data(i).t1_volt];
        t2_volt = [data(i).t2_volt];
        a1_g = [data(i).a1_g];
        a2_g = [data(i).a2_g];
        a3_g = [data(i).a3_g];
    else
        dnum = [dnum; data(i).dnum];
        s1_volt = [s1_volt; data(i).s1_volt];
        s2_volt = [s2_volt; data(i).s2_volt];
        t1_volt = [t1_volt; data(i).t1_volt];
        t2_volt = [t2_volt; data(i).t2_volt];
        a1_g = [a1_g; data(i).a1_g];
        a2_g = [a2_g; data(i).a2_g];
        a3_g = [a3_g; data(i).a3_g];
    end
end
clear data temp i;
load profiles\epsi\PressureTimeseries.mat;
load profiles\epsi\TimeIndex.mat;
save concatenated.mat;

%% load concatenated file
load concatenated.mat;
% create concatenated struct called data
data.dnum = dnum;
data.s1_volt = s1_volt;
data.s2_volt = s2_volt;
data.t1_volt = t1_volt;
data.t2_volt = t2_volt;
data.a1_g = a1_g;
data.a2_g = a2_g;
data.a3_g = a3_g;
data.PressureTimeseries = PressureTimeseries;
data.TimeIndex = TimeIndex;

%% pick a single profile
profile_num = 6;
profile = pick_profile(data, profile_num);

%% plot shear and pressure for a single profile
figure(1)
clf
yyaxis left
plot(profile.P_dnum, profile.P)
ylabel('Pressure (dbar)')
set(gca, 'YDir', 'reverse')
hold on
yyaxis right
ylabel('Shear (Volts)')
plot(profile.dnum, profile.s2_volt)%, profile.dnum, profile.s2_volt);
datetick('x', 13)
title({'Single APEX-epsi Profile', sprintf('%s', datetime(mean(profile.dnum),'ConvertFrom','datenum', 'Format', 'dd-MMM-uuuu'))})
xlabel('Time')

%% quick zoomed in a1 plot
figure
start = 7.385370876794676e+05;
finish = 7.385370879e+05;
mask = profile.dnum > start & profile.dnum < finish;
plot(profile.dnum(mask), profile.a1_g(mask));
xlabel('time')
datetick('x', 13)
ylabel('a1 (g)')
title({'Acceleration for APEX-epsi', 'standard ascent profile'})
% starts of high noise sections

%% pull out indices for 10 noisy sections and 10 good sections from profile #1 and #6 as applicable

low_noise_num_samples = 3600;
high_noise_num_samples = 9500;
transition_buffer = 250;
if profile_num == 1
    low_noise_idx = [190236:190236 + low_noise_num_samples; 203597:203597 + low_noise_num_samples;...
        217202:217202 + low_noise_num_samples; 230892:230892 + low_noise_num_samples;...
        244280:244280 + low_noise_num_samples; 257875:257875 + low_noise_num_samples;...
        271539:271539 + low_noise_num_samples;... %285495:285495 + num_samples;...
        298876:298876 + low_noise_num_samples; 312576:312576 + low_noise_num_samples;...
        326239:326239 + low_noise_num_samples; 339904:339904 + low_noise_num_samples];
    high_noise_idx = nan(size(low_noise_idx, 1), high_noise_num_samples + 1);
    for i = 1:size(low_noise_idx, 1)
        high_noise_idx(i, :) = low_noise_idx(i, end) + transition_buffer:...
        low_noise_idx(i, end) + transition_buffer + high_noise_num_samples;
    end
elseif profile_num == 6
    low_noise_num_samples = 9500;
    high_noise_sample_nums = [917771, 931154, 1528750, 1542140, 2139430, 2454510];
    low_noise_sample_nums = [76036, 386691, 651981, 1685480, 1854840, 2048600];
    high_noise_idx = zeros(length(high_noise_sample_nums), high_noise_num_samples + 1);
    low_noise_idx = zeros(length(low_noise_sample_nums), low_noise_num_samples + 1);
    for i = 1:length(high_noise_sample_nums)
        high_noise_idx(i, :) = [high_noise_sample_nums(i):high_noise_sample_nums(i) + high_noise_num_samples];
    end
    for i = 1:length(low_noise_sample_nums)
        low_noise_idx(i, :) = [low_noise_sample_nums(i):low_noise_sample_nums(i) + low_noise_num_samples];
    end
end
low_noise_s2_volt = nan(size(low_noise_idx));
low_noise_a1 = nan(size(low_noise_idx));
low_noise_a2 = nan(size(low_noise_idx));
low_noise_a3 = nan(size(low_noise_idx));;
for i = 1:size(low_noise_s2_volt, 1)
    low_noise_s2_volt(i, :) = profile.s2_volt(low_noise_idx(i, :));
    low_noise_a1(i, :) = profile.a1_g(low_noise_idx(i, :));
    low_noise_a2(i, :) = profile.a2_g(low_noise_idx(i, :));
    low_noise_a3(i, :) = profile.a3_g(low_noise_idx(i, :));
end
high_noise_s2_volt = nan(size(low_noise_idx, 1), high_noise_num_samples + 1);
high_noise_a1 = nan(size(low_noise_idx, 1), high_noise_num_samples + 1);
high_noise_a2 = nan(size(low_noise_idx, 1), high_noise_num_samples + 1);
high_noise_a3 = nan(size(low_noise_idx, 1), high_noise_num_samples + 1);
for i = 1:size(high_noise_idx, 1)
    high_noise_s2_volt(i, :) = profile.s2_volt(high_noise_idx(i, :));
    high_noise_a1(i, :) = profile.a1_g(high_noise_idx(i, :));
    high_noise_a2(i, :) = profile.a2_g(high_noise_idx(i, :));
    high_noise_a3(i, :) = profile.a3_g(high_noise_idx(i, :));
end

%% plot low and high noise sections
% low noise
figure(2)
clf
plot(low_noise_s2_volt')
ylim([-.01, .01])
xlabel('Sample Number')
ylabel('Shear (Volts)')
title(sprintf('%d selected low noise measurements', size(low_noise_idx, 1)))
% high noise
figure(3)
clf
plot(high_noise_s2_volt')
ylim([-.01, .01])
xlabel('Sample Number')
ylabel('Shear (Volts)')
title(sprintf('%d selected high noise measurements', size(high_noise_idx, 1)))
% legend('1', '2', '3', '4', '5', '6')

%% compute spectra for both low and high noise data
fs = 320;
[low_noise_s2_volt_spectra, f_low] = pwelch(detrend(low_noise_s2_volt', 0), [], [], [], fs);
[high_noise_s2_volt_spectra, f_high] = pwelch(detrend(high_noise_s2_volt', 0), [], [], [], fs);
[low_noise_a1_spectra] = pwelch((detrend(low_noise_a1')));
[high_noise_a1_spectra] = pwelch(detrend(high_noise_a1'));
[low_noise_a2_spectra] = pwelch(detrend(low_noise_a2'));
[high_noise_a2_spectra] = pwelch(detrend(high_noise_a2'));
[low_noise_a3_spectra] = pwelch(detrend(low_noise_a3'));
[high_noise_a3_spectra] = pwelch(detrend(high_noise_a3'));

%% plot spectra for low and high noise data
% low noise
figure(4)
loglog(f_low, low_noise_s2_volt_spectra)
xlim([f_low(2), f_low(end)])
ylim([10^-14, 10^-7])
xlabel('Frequency (Hz)')
ylabel('PSD (V^2/Hz)')
title(sprintf('%d selected low noise spectra', size(low_noise_idx, 1)))
% high noise
figure(5)
loglog(f_high, high_noise_s2_volt_spectra)
xlim([f_low(2), f_low(end)])
ylim([10^-14, 10^-7])
xlabel('Frequency (Hz)')
ylabel('PSD (V^2/Hz)')
title(sprintf('%d selected high noise spectra', size(low_noise_idx, 1)))

% acceleration
% figure(6)
% loglog(f_high, high_noise_a3_spectra)

%% single comparison
section_num = 1;
figure(6)
clf
subplot(2, 1, 1)
plot(high_noise_s2_volt(section_num, :))
hold on
plot(low_noise_s2_volt(section_num, :))
ylim([-.01, .01])
xlabel('Sample Number')
ylabel('Shear (Volts)')
title('Data')
legend('High Noise', 'Low Noise', 'Location', 'north')
subplot(2, 1, 2)
loglog(f_high, high_noise_s2_volt_spectra(:, section_num))
hold on
loglog(f_low, low_noise_s2_volt_spectra(:, section_num))
xlim([f_low(2), f_low(end)])
ylim([10^-14, 10^-7])
xlabel('Frequency (Hz)')
ylabel('PSD (V^2/Hz)')
title('Spectra')
legend('High Noise', 'Low Noise', 'Location', 'north')
sgtitle(['Single High Noise - Low Noise Comparison'])

%% compare a single low-noise shear and acceleration in area with oscillations
figure(7)
clf
% subplot(2, 1, 1)
yyaxis left
plot(low_noise_s2_volt(section_num, :))
ylim([-.01, .01])
ylabel('Shear (Volts)')
yyaxis right
plot(low_noise_a3(section_num, :))
xlabel('Sample Number')
ylabel('Acceleration (g)')
title('Single Low Noise Section Shear and a3 Comparison')
legend('Shear', 'a3')
% subplot(2, 1, 2)
% yyaxis left
% loglog(f_low, low_noise_s2_volt_spectra(:, section_num))
% xlim([f_low(2), f_low(end)])
% xlabel('Frequency (Hz)')
% ylim([10^-14, 10^-9])
% ylabel('PSD (V^2/Hz)')
% yyaxis right
% loglog(f_low, low_noise_a1_spectra(:, section_num))
% ylabel('PSD(g^2/Hz)')
% ylim([10^-7, 10^-2])
% title('Spectra')
% legend('Shear', 'Acceleration', 'Location', 'Southwest')
% sgtitle(['Single Low Noise Section Shear and a1 Comparison'])
% closer look at acceleration spectrum
figure(8)
clf
yyaxis left
loglog(f_low, low_noise_s2_volt_spectra(:, section_num))
xlim([f_low(2), f_low(end)])
xlabel('Frequency (Hz)')
ylim([10^-14, 10^-9])
ylabel('PSD (V^2/Hz)')
yyaxis right
loglog(f_low, low_noise_a3_spectra(:, section_num))
ylabel('PSD(g^2/Hz)')
ylim([10^-10, 10^-7])
title('Single Low Noise Section Shear and a3 Spectra')
legend('Shear', 'Acceleration', 'Location', 'Southwest')

%% compute coherence
low_noise_s2_a1_coherence = mscohere(detrend(low_noise_s2_volt'), detrend(low_noise_a1'));
high_noise_s2_a1_coherence = mscohere(detrend(high_noise_s2_volt'), detrend(high_noise_a1'));
low_noise_s2_a2_coherence = mscohere(detrend(low_noise_s2_volt'), detrend(low_noise_a2'));
high_noise_s2_a2_coherence = mscohere(detrend(high_noise_s2_volt'), detrend(high_noise_a2'));
low_noise_s2_a3_coherence = mscohere(detrend(low_noise_s2_volt'), detrend(low_noise_a3'));
high_noise_s2_a3_coherence = mscohere(detrend(high_noise_s2_volt'), detrend(high_noise_a3'));

%% plot coherence
figure(9)
clf
semilogx(f_low, low_noise_s2_a3_coherence)
xlim([0.3 160])
xlabel('Frequency (Hz)')
ylabel('Magnitude Squared Coherence')
title({'Coherence between s2(V) and a3(g)', sprintf('for %d selected low noise measurements', size(high_noise_idx, 1))})
figure(10)
clf
semilogx(f_high, high_noise_s2_a3_coherence)
xlim([0.3 160])
xlabel('Frequency (Hz)')
ylabel('Magnitude Squared Coherence')
title({'Coherence between s2(V) and a3(g)', sprintf('for %d selected high noise measurements', size(high_noise_idx, 1))})
% now plot means
figure(11)
clf
semilogx(f_low, mean(low_noise_s2_a3_coherence, 2))
hold on
semilogx(f_high, mean(high_noise_s2_a3_coherence, 2))
xlim([0.3 160])
xlabel('Frequency (Hz)')
ylabel('Magnitude Squared Coherence')
legend('Low Noise', 'High Noise')
title({'Mean coherence between s2(V) and a3(g)', sprintf('for %d selected low and high noise measurements', size(high_noise_idx, 1))})
% now plot just one
section_num = 1;
figure(12)
clf
semilogx(f_low, low_noise_s2_a3_coherence(:, section_num))
xlim([0.3 160])
xlabel('Frequency (Hz)')
ylabel('Magnitude Squared Coherence')
title({'Coherence between s2(V) and a3(g)', 'for a single low noise period (same one as above)'})
%% plot shear and pressure
figure
yyaxis left
ylabel('Pressure (dbar)')
plot(PressureTimeseries.dnum, PressureTimeseries.P)
set(gca, 'YDir','reverse')
yyaxis right
plot(dnum, s2_volt)
ylabel('Shear (Volts)')
datetick

%% plot pressure and rise speed of profiles
rise_rate = -diff(PressureTimeseries.P)./(diff(PressureTimeseries.dnum)*24*3600);
profile.rise_rate = -diff(profile.P)./(diff(profile.P_dnum)*24*3600);
figure(13)
clf
yyaxis left
plot(PressureTimeseries.dnum, PressureTimeseries.P)
ylim([0 800])
set(gca, 'YDir','reverse')
ylabel('Pressure (dbar)')
yyaxis right
plot(PressureTimeseries.dnum(2:end), rise_rate)
ylabel('Rise Rate (dbar/s)')
xlabel('Time')
datetick('x', 6)
xlim([PressureTimeseries.dnum(5) PressureTimeseries.dnum(27964)])

title({'APEX-epsi float pressure and rise rate', 'for standalone deployment Feb 2022'})
figure(14)
clf
yyaxis left
plot(profile.P_dnum, profile.P)
set(gca, 'YDir','reverse')
ylabel('Pressure (dbar)')
yyaxis right
plot(profile.P_dnum(2:end), profile.rise_rate)
ylabel('Rise Rate (dbar/s)')
xlabel('Time')
datetick('x', 13)
title({'APEX-epsi float pressure and rise rate', 'for single profile of standalone deployment Feb 2022'})
%% plot shear and acceleration
figure
yyaxis left
plot(dnum, s1_volt)
yyaxis right
plot(dnum, a1_g, dnum, a2_g, dnum, a3_g)
legend('s1', 'a1', 'a2', 'a3')





%%
function y = haf_oakey(f,w)
    % haf_oakey
    %   Usage: y = haf_oakey(f,w)
    %	   f is frequency in a column vector, 
    %      w is the fall rate
    %   Function: Power transfer function of airfoil probe according
    %   to Oakey
    
    lc=0.02;
    y = 1 ./ (1 + (lc .* (f' / w) ).^2 );
    y=y';
end