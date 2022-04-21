function [fig, ax] = plot_standalone_deployment(standard_ascent, yoyo)


    %UNTITLED4 Summary of this function goes here
    %   Detailed explanation goes here
    if nargin > 1
        profile = [yoyo, standard_ascent];
        num_yoyo = length(yoyo);
    else
        profile = standard_ascent;
    end
    fig = figure;
    fs = 16;
    hold on
    z_max = max(profile(1).z);
    t_min = min(profile(1).dnum);
    t_max = max(profile(1).dnum);
    for i = 1:length(profile)
        ax(i) = plot(profile(i).dnum, profile(i).z, 'Color','black', 'LineWidth',2);
        if max(profile(i).z > z_max)
            z_max = max(profile(i).z);
        end
        if min(profile(i).dnum < t_min)
            t_min = min(profile(i).dnum);
        end
        if max(profile(i).dnum > t_max)
            t_max = max(profile(i).dnum);
        end
    end
    x_buffer = .1;
    y_buffer = 50;
    ylim([0 z_max + y_buffer])
    set(gca, 'YDir','reverse')
    datetick('x', 2)
    xlim([t_min - x_buffer, t_max + x_buffer])
    xlabel('Time', 'FontSize',fs)
    ylabel('Depth (m)', 'FontSize',fs)
    if nargin > 1
        x_buffer = .04;
        x_yoyo = [min(yoyo(1).dnum) - x_buffer, max(yoyo(end).dnum) + x_buffer,...
             max(yoyo(end).dnum) + x_buffer, min(yoyo(1).dnum) - x_buffer];
        y_yoyo = [0, 0, z_max + y_buffer, z_max + y_buffer];
        patch(x_yoyo, y_yoyo, 'blue', 'FaceAlpha',0.15);
        text(mean([x_yoyo(1), x_yoyo(2)]), z_max + y_buffer/2, 'Yoyo Mode', 'FontSize',fs, 'HorizontalAlignment','center')
        text(mean([x_yoyo(2) - x_buffer, t_max]), z_max + y_buffer/2, 'Standard Ascent Mode', 'FontSize',fs, 'HorizontalAlignment','center')
    end
    title('Standalone APEX-epsi Deployment', 'FontSize',fs);

end