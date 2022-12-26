function is_histogram_valid = HistogramBasedValidation(self, candidate_delay, param) 
  fraction = 1.0;
  histogram_threshold = self.histogram(self.compare_delay + 1);
  delay_difference = candidate_delay - self.ast_delay;

%   // The histogram based validation of |candidate_delay| is done by comparing
%   // the |histogram| at bin |candidate_delay| with a |histogram_threshold|.
%   // This |histogram_threshold| equals a |fraction| of the |histogram| at bin
%   // |last_delay|.  The |fraction| is a piecewise linear function of the
%   // |delay_difference| between the |candidate_delay| and the |last_delay|
%   // allowing for a quicker move if
%   //  i) a potential echo control filter can not handle these large differences.
%   // ii) keeping |last_delay| instead of updating to |candidate_delay| could
%   //     force an echo control into a non-causal state.
%   // We further require the histogram to have reached a minimum value of
%   // |kMinHistogramThreshold|.  In addition, we also require the number of
%   // |candidate_hits| to be more than |kMinRequiredHits| to remove spurious
%   // values.

%   // Calculate a comparison histogram value (|histogram_threshold|) that is
%   // depending on the distance between the |candidate_delay| and |last_delay|.
%   // TODO(bjornv): How much can we gain by turning the fraction calculation
%   // into tables?
  if (delay_difference > self.allowed_offset) 
    fraction = 1.0 - param.kFractionSlope * (delay_difference - self.allowed_offset);
    fraction = max(fraction, param.kMinFractionWhenPossiblyCausal);
  elseif (delay_difference < 0) 
    fraction = param.kMinFractionWhenPossiblyNonCausal -...
        param.kFractionSlope * delay_difference;
    fraction = min(fraction, 1.0);
  end
  histogram_threshold = histogram_threshold*fraction; 
  histogram_threshold = max(histogram_threshold, param.kMinHistogramThreshold);

  is_histogram_valid =...
      (self.histogram(candidate_delay + 1) >= histogram_threshold) &&...
      (self.candidate_hits > param.kMinRequiredHits);

