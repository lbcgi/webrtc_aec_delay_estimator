function quality = WebRtc_last_delay_quality(self, param)
  selfb = self.binary_handle;
%   RTC_DCHECK(self);
  if (selfb.robust_validation_enabled) 
%     // Simply a linear function of the histogram height at delay estimate.
    quality = selfb.histogram(selfb.compare_delay + 1) / param.kHistogramMax;
  else 
%     // Note that |last_delay_probability| states how deep the minimum of the
%     // cost function is, so it is rather an error probability.
    quality = (param.kMaxBitCountsQ9 - selfb.last_delay_probability) /...
        param.kMaxBitCountsQ9;
    if (quality < 0) 
      quality = 0;
    end
 end
