function [fig, ax] = plot_epsilon_profiles(profile)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    fig = figure;
    fs = 14;
    tiledlayout(1, 4, 'TileSpacing','compact')
    for i = 1:length(profile)
        mask = profile(i).epsilon(:, 2) > 1e-10;
        if isfield(profile(i), 'pump')
            mask = mask & ~(profile(i).pump.flag);
        end
        if isfield(profile(i), 'spike')
            mask = mask & ~(profile(i).spike.flag);
        end
        nexttile
        eps_plot = profile(i).epsilon(:, 2);
        eps_plot(~mask) = NaN;
        ax(i) = gca;
        semilogx(eps_plot, profile(i).z(:));
        if i ~= 1
            set(gca, 'YTick', [])
        end
        set(gca, 'YDir', 'reverse')
        ax(i).XTick = [10^-10 10^-6];
        xlabel('\epsilon (W/kg)')
        title({sprintf('Profile %d', 6 + i), datestr(mean(profile(i).dnum, 'omitnan'), 'mm/dd-HHAM')})
        ax(i).FontSize = fs;
    end
    linkaxes(ax(1:end), 'xy');
    ylabel(ax(1), 'Depth(m)')
    max_depth = 0;
    for i = 1:length(profile)
        if max_depth < max(abs(profile(i).z))
        max_depth = max(abs(profile(i).z));
        end
    end
    ax(1).YLim = [0 max_depth];
%     ax(1).XLim = [10^-10 10^-5];
end