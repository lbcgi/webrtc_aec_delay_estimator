function mean_value = WebRtc_MeanEstimatorFix(new_value, factor, mean_value)
    mean_value = mean_value + (new_value - mean_value)/2^factor;
end