function profile = remove_shearspikes(profile, threshold);


    %UNTITLED3 Summary of this function goes here
    %   Detailed explanation goes here
    
    for i = 1:length(profile)
        % create a detrended shear field for each scan
        profile(i).spike.detrended_shear = nan(profile(i).nbscan, profile(i).nfft*2);
        profile(i).spike.flag = zeros(profile(i).nbscan, 1);
        for j = 1:profile(i).nbscan
            idx = profile(i).ind_range_epsi(j, 1):profile(i).ind_range_epsi(j, end);
            if ~isnan(idx)
                profile(i).spike.detrended_shear(j, :) = detrend(profile(i).epsi.s2_volt(idx));
                stddev = std(profile(i).spike.detrended_shear(j, :));
                comp = (profile(i).spike.detrended_shear(j, :) > threshold*stddev);
                if sum(comp) > 0
                    profile(i).spike.flag(j) = 1;
                end
            end
        end
    end

    
end