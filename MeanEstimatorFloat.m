function mean_value = MeanEstimatorFloat(new_value, scale, mean_value)
    mean_value = mean_value + (new_value - mean_value)*scale;
end