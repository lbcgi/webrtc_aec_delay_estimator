function [out, threshold_spectrum, threshold_initialized] = BinarySpectrumFloat(spectrum, threshold_spectrum, threshold_initialized, param) 
  out = 0;
  kScale = 1 / 64.0;

  if (~(threshold_initialized)) 
%     // Set the |threshold_spectrum| to half the input |spectrum| as starting
%     // value. This speeds up the convergence.
    for i = param.kBandFirst:param.kBandLast
      if (spectrum(i + 1) > 0.0) 
        threshold_spectrum(i + 1).float_ = (spectrum(i + 1) / 2);
        threshold_initialized = 1;
      end
    end
 end

  for i = param.kBandFirst: param.kBandLast
%     // Update the |threshold_spectrum|.
    threshold_spectrum(i + 1).float_ = MeanEstimatorFloat(spectrum(i + 1), kScale, (threshold_spectrum(i + 1).float_));
%     // Convert |spectrum| at current frequency bin to a binary value.
    if (spectrum(i + 1) > threshold_spectrum(i + 1).float_) 
%       out = SetBit(out, i - param.kBandFirst);
        out = bitset(out, i - param.kBandFirst + 1);
    end
  end

end