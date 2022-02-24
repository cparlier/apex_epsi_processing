function profile = pick_profile(data, profile_num)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

pressure_mask = diff(data.PressureTimeseries.P) < 0;
P = data.PressureTimeseries.P(pressure_mask);
% P = P(~isnan(P));
P_dnum = data.PressureTimeseries.dnum(pressure_mask);
[pks, idx] = findpeaks(diff(P_dnum), "Threshold", 0.06);
if profile_num == length(idx)
    profile.P = P(idx(profile_num) + 1:end);
    profile.P_dnum = P_dnum(idx(profile_num) + 1:end);
else
    profile.P = P(idx(profile_num) + 1:idx(profile_num + 1));
    profile.P_dnum = P_dnum(idx(profile_num) + 1:idx(profile_num + 1));
end

profile.start = profile.P_dnum(1);
profile.end = profile.P_dnum(end);
epsi_mask = (data.dnum > profile.start) & (data.dnum < profile.end);
profile.dnum = data.dnum(epsi_mask);
profile.s2_volt = data.s2_volt(epsi_mask);
profile.t2_volt = data.t2_volt(epsi_mask);
profile.a1_g = data.a1_g(epsi_mask);
profile.a2_g = data.a2_g(epsi_mask);
profile.a3_g = data.a3_g(epsi_mask);

end