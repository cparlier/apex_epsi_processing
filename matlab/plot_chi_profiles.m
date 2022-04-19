function [fig, ax] = plot_chi_profiles(profile)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    fig = figure;
    width = 1/length(profile) - 0.025;
    height = 0.725;
    fs = 14;
    for i = 1:length(profile)
        mask = profile(i).chi(:, 2) > 1e-12;
        ax(i) = subplot('Position', [(i - 1)*width + 0.065, .1, width, height]);
        chi_plot = profile(i).chi(:, 2);
        chi_plot(~mask) = NaN;
        semilogx(chi_plot, profile(i).z(:));
        if i ~= 1
            set(gca, 'YTick', [])
        end
        set(gca, 'YDir', 'reverse')
%         ax(i).XTick = [10^-10 10^-6];
        xlabel('\chi (K^2/s)')
        title(sprintf('Profile %d', 6 + i))
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