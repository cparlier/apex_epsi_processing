function [fig, ax] = plot_chi_profiles(profile)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    fig = figure;
    fs = 14;
    tiledlayout(1, 4, 'TileSpacing','compact')
    for i = 1:length(profile)
        mask = profile(i).chi(:, 2) > 1e-12;
        chi_plot = profile(i).chi(:, 2);
        chi_plot(~mask) = NaN;
        nexttile
        ax(i) = gca;
        semilogx(chi_plot, profile(i).z(:));
        if i ~= 1
            set(gca, 'YTick', [])
        end
        set(gca, 'YDir', 'reverse')
        xlabel('\chi (K^2/s)')
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

end