function [fig, ax] = plot_shear_panchev_binned_epsilons(profile, targets, range, accelplots)

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%     idx = NaN(length(targets), length(profile));
    if nargin < 4
        accelplots = 0;
    end
    legend_array = cell(1, length(targets)*2);
    fig(1) = figure;
    target_range = range;
    shear_spec = zeros(length(targets), profile(1).nfft/2 + 1);
    k_spec = zeros(size(shear_spec));
    kvis_spec = zeros(length(targets));
    accel_spec = zeros(size(shear_spec));
    coh = zeros(size(accel_spec));
    w = zeros(length(targets));
    g = 9.81;
    num_inrange = nan(length(profile), 1);
    for j = 1:length(targets)
        for i = 1:length(profile)
            mask = profile(i).epsilon(:, 2) > 1e-10;
            if isfield(profile(i), 'pump')
                mask = mask & ~(profile(i).pump.flag);
            end
            if isfield(profile(i), 'spike')
                mask = mask & ~(profile(i).spike.flag);
            end
            mask = mask & (profile(i).epsilon(:, 2) > target_range(j, 1)) & (profile(i).epsilon(:, 2) < target_range(j, end));
            temp_spec = profile(i).Ps_shear_k.s2(mask, :);
            temp_k = profile(i).k(mask, :);
            temp_kvis = profile(i).kvis(mask);
            num_inrange(i) = size(temp_spec, 1);
            shear_spec(j, :) = shear_spec(j, :) + sum(temp_spec, 1);
            k_spec(j, :) = k_spec(j, :) + sum(temp_k, 1);
            kvis_spec(j) = kvis_spec(j) + sum(temp_kvis);
            if accelplots
                temp_accel = profile(i).Pa_g_f.a3(mask, :);
                temp_w = profile(i).w(mask);
                temp_coh = profile(i).Cs2a3_scan(mask, :);
                coh(j, :) = coh(j, :) + sum(temp_coh, 1);
                accel_spec(j, :) = accel_spec(j, :) + sum(temp_accel, 1);
                w(j) = w(j) + sum(temp_w);
            end
        end
        shear_spec(j, :) = shear_spec(j, :)/sum(num_inrange);
        k_spec(j, :) = k_spec(j, :)/sum(num_inrange);
        kvis_spec(j) = kvis_spec(j)/sum(num_inrange);
        if accelplots
            w(j) = w(j)/sum(num_inrange);
            accel_spec(j, :) = accel_spec(j, :)/sum(num_inrange);
            accel_spec(j, :) = accel_spec(j, :)./(abs(w(j))*g^2);
            coh(j, :) = coh(j, :)./sum(num_inrange);
        end
        spec(j) = loglog(k_spec(j, 3:end), shear_spec(j, 3:end));
        hold on
        ax(1) = gca;
        color = get(spec(j), 'Color');
        [k_panchev, spec_panchev] = panchev(targets(j), kvis_spec(j));
        loglog(k_panchev, spec_panchev, 'k--')
        buffer = 0.2;
        x_start = 0.5;
        if ~isnan(k_panchev)
            [val, idx] = min(abs((x_start + x_start*buffer) - k_panchev));
            text(x_start + x_start*buffer, spec_panchev(idx), sprintf('\\epsilon = 10^{%.2g}', log10(targets(j))), 'VerticalAlignment','cap')
        end
        if targets(j) <= 10^-10;
            legend_array{2*j - 1} = 'log_{10}\epsilon = -10';
        else
            legend_array{2*j - 1} = sprintf('%.3g < log_{10}\\epsilon < %.2g', log10(range(j, 1)), log10(range(j, end)));
        end
        legend_array{2*j} = '';
    
    end
    ylim([10^-7 .1])
    xlim([x_start 500])
    legend(legend_array, 'Location', 'best', 'AutoUpdate', 'off');
    hold off
    xlabel('wavenumber (cpm)')
    ylabel('\Phi_{shear} (s^{-2}/cpm)')
    title({'APEX-epsi standalone deployment', 'binned shear wavenumber spectra'})

    if accelplots
        fig(2) = figure;
        accel_legend = cell(1, length(targets));
        tiledlayout(2, 1, 'TileSpacing','none');
        ax(2) = nexttile;
        ax(3) = nexttile;
        for j = 1:length(targets)
            set(gcf, 'CurrentAxes', ax(2));
            loglog(k_spec(j, 2:end), accel_spec(j, 2:end));
            hold on
            if targets(j) <= 10^-10;
                accel_legend{j} = 'log_{10}\epsilon = -10';
            else
                accel_legend{j} = sprintf('%.3g < log_{10}\\epsilon < %.2g', log10(range(j, 1)), log10(range(j, end)));
            end
            set(gcf, 'CurrentAxes', ax(3));
            semilogx(k_spec(j, :), coh(j, :));
            hold on
        end
        nexttile(1);
        legend(accel_legend);
        xticks([]);
        ylabel('\Phi_{a3} (s^{-2}/cpm)')
        title({'APEX-epsi standalone deployment', 'binned acceleration wavenumber spectra'})
        nexttile(2);
        ylabel('a3-shear coherence')
        linkaxes(ax(2:3), 'x');
        xlim([min(k_spec, [], 'all') max(k_spec, [], 'all')])
        xlabel('wavenumber (cpm)')
    end


end