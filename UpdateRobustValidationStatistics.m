function self = UpdateRobustValidationStatistics(self, candidate_delay, valley_depth_q14, valley_level_q14, param) 
  valley_depth = valley_depth_q14 * param.kQ14Scaling;
  decrease_in_last_set = valley_depth;
  
  if(candidate_delay < self.last_delay)
      max_hits_for_slow_change = param.kMaxHitsWhenPossiblyNonCausal;
  else
      max_hits_for_slow_change = param.kMaxHitsWhenPossiblyCausal;
  end

%   RTC_DCHECK_EQ(self->history_size, self->farend->history_size);
%   // Reset |candidate_hits| if we have a new candidate.
  if (candidate_delay ~= self.last_candidate_delay) 
    self.candidate_hits = 0;
    self.last_candidate_delay = candidate_delay;
  end
  self.candidate_hits = self.candidate_hits + 1;

%   // The |histogram| is updated differently across the bins.
%   // 1. The |candidate_delay| histogram bin is increased with the
%   //    |valley_depth|, which is a simple measure of how reliable the
%   //    |candidate_delay| is.  The histogram is not increased above
%   //    |kHistogramMax|.
  self.histogram(candidate_delay + 1) =  self.histogram(candidate_delay + 1) + valley_depth;
  if (self.histogram(candidate_delay + 1) > param.kHistogramMax) 
        self.histogram(candidate_delay + 1) = param.kHistogramMax;
  end
%   // 2. The histogram bins in the neighborhood of |candidate_delay| are
%   //    unaffected.  The neighborhood is defined as x + {-2, -1, 0, 1}.
%   // 3. The histogram bins in the neighborhood of |last_delay| are decreased
%   //    with |decrease_in_last_set|.  This value equals the difference between
%   //    the cost function values at the locations |candidate_delay| and
%   //    |last_delay| until we reach |max_hits_for_slow_change| consecutive hits
%   //    at the |candidate_delay|.  If we exceed this amount of hits the
%   //    |candidate_delay| is a "potential" candidate and we start decreasing
%   //    these histogram bins more rapidly with |valley_depth|.
  if (self.candidate_hits < max_hits_for_slow_change) 
    decrease_in_last_set = (self.mean_bit_counts(self.compare_delay + 1) -...
        valley_level_q14) * param.kQ14Scaling;
  end
%   // 4. All other bins are decreased with |valley_depth|.
%   // TODO(bjornv): Investigate how to make this loop more efficient.  Split up
%   // the loop?  Remove parts that doesn't add too much.
  for i = 0:self.history_size - 1
    is_in_last_set = (i >= self.last_delay - 2) &&...
        (i <= self.last_delay + 1) && (i ~= candidate_delay);
    is_in_candidate_set = (i >= candidate_delay - 2) &&...
        (i <= candidate_delay + 1);
    self.histogram(i + 1) = self.histogram(i + 1) - decrease_in_last_set * is_in_last_set +...
        valley_depth * (~is_in_last_set && ~is_in_candidate_set);
%     // 5. No histogram bin can go below 0.
    if (self.histogram(i + 1) < 0) 
      self.histogram(i + 1) = 0;
    end
  end
end