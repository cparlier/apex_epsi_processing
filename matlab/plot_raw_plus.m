function [fig, ax] = plot_raw_plus(profile)

    %UNTITLED Summary of this function goes here
    % plot for each standard ascent profile of shear, temp or T', a3, epsilon,
    % chi, rise rate
    
    for i = 1:length(profile)
        fig(i) = figure;
        z_max = max(profile(i).z);
        z_epsi = interp1(1:length(profile(i).ctd.z), profile(i).ctd.z, linspace(1, length(profile(i).ctd.z), length(profile(i).epsi.s2_volt)));
        tiledlayout(1, 6, 'TileSpacing','tight')
        % shear
        nexttile
        ax(i, 1) = plot(profile(i).epsi.s2_volt, z_epsi);
        xlabel('Volts')
        ylabel('Depth (m)')
        set(gca, 'YDir', 'reverse')
        title('s')
        % T
        nexttile
        ax(i, 2) = plot(profile(i).epsi.t2_volt, z_epsi);
        xlabel('Volts')
        set(gca, 'YDir', 'reverse')
        title('T')
        yticks([]);
        % a3
        nexttile
        ax(i, 3) = plot(profile(i).epsi.a3_g, z_epsi);
        xlabel('g')
        set(gca, 'YDir', 'reverse')
        title('a3')
        yticks([]);
        % epsilon
        mask = profile(i).epsilon(:, 2) > 1e-10;
        if isfield(profile(i), 'pump')
            mask = mask & ~(profile(i).pump.flag);
        end
        if isfield(profile(i), 'spike')
            mask = mask & ~(profile(i).spike.flag);
        end
        eps_plot = profile(i).epsilon(:, 2);
        eps_plot(~mask) = NaN;
        nexttile
        ax(i, 4) = semilogx(eps_plot, profile(i).z);
        xlabel('W/kg')
        set(gca, 'YDir', 'reverse')
        title('\epsilon')
        yticks([]);
        % chi
        nexttile
        ax(i, 5) = semilogx(profile(i).chi(:, 2), profile(i).z);
        xlabel('K^2/s')
        set(gca, 'YDir', 'reverse')
        title('\chi')
        yticks([]);
        % rise rate
        nexttile
        ax(i, 6) = plot(abs(profile(i).w), profile(i).z);
        xlabel('m/s')
        set(gca, 'YDir', 'reverse')
        title('Rise Rate')
        yticks([]);
        sgtitle({'Standalone APEX-epsi Deployment', sprintf('Profile %d - %s', profile(i).profNum, datestr(mean(profile(i).dnum, 'omitnan'), 'mm/dd -HHAM'))})
    end

end