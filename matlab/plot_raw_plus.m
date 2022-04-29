function [fig, ax] = plot_raw_plus(profile)

    %UNTITLED Summary of this function goes here
    % plot for each standard ascent profile of shear, temp or T', a3, epsilon,
    % chi, rise rate
    
    for i = 1:length(profile)
        fig(i) = figure;
        z_max = max(profile(i).z);
        z_epsi = interp1(1:length(profile(i).ctd.z), profile(i).ctd.z, linspace(1, length(profile(i).ctd.z), length(profile(i).epsi.s2_volt)));
        tiledlayout(1, 6, 'TileSpacing','none')
        % shear
        nexttile
        plot(profile(i).epsi.s2_volt, z_epsi);
        ax(i, 1) = gca;
        xlabel('Volts')
        ylabel('Depth (m)')
        set(gca, 'YDir', 'reverse')
        title('s')
        xticks([-.25 0 .25])
        grid on
        % T
        nexttile
        plot(profile(i).epsi.t2_volt, z_epsi);
        ax(i, 2) = gca;
        xlabel('Volts')
        set(gca, 'YDir', 'reverse')
        title('T')
        yticks([]);
        grid on
        % a3
        nexttile
        plot(profile(i).epsi.a3_g, z_epsi);
        ax(i, 3) = gca;
        xlabel('g')
        set(gca, 'YDir', 'reverse')
        title('a3')
        yticks([]);
        grid on
        % rise rate
        nexttile
        plot(abs(profile(i).w), profile(i).z);
        ax(i, 4) = gca;
        xlabel('m/s')
        set(gca, 'YDir', 'reverse')
        title('Rise Rate')
        yticks([]);
        grid on
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
        semilogx(eps_plot, profile(i).z);
        ax(i, 5) = gca;
        xlabel('W/kg')
        set(gca, 'YDir', 'reverse')
        title('\epsilon')
        yticks([]);
        grid on;
        % chi
        nexttile
        semilogx(profile(i).chi(:, 2), profile(i).z);
        ax(i, 6) = gca;
        xlabel('K^2/s')
        set(gca, 'YDir', 'reverse')
        title('\chi')
        yticks([]);
        grid on;
        set(ax(i, 1:6), 'FontSize', 14)
        sgtitle({'Standalone APEX-epsi Deployment',...
            sprintf('Profile %d - %s', profile(i).profNum, datestr(mean(profile(i).dnum, 'omitnan'), 'mm/dd -HHAM'))},...
            'FontSize',14)
    end

end