function [delay_est, self] = WebRtc_ProcessBinarySpectrum(self, binary_near_spectrum, param)
    
    candidate_delay = -1;
%     valid_candidate = 0;
    value_best_candidate = param.kMaxBitCountsQ9;
    value_worst_candidate = 0;
%     valley_depth = 0;
    
%     param.kHistorySizeBlocks
    self.bit_counts = BitCountComparison(binary_near_spectrum, self.farend.binary_far_history, ...
        self.history_size);

    %  Update |mean_bit_counts|, which is the smoothed version of |bit_counts|.
      for i = 0:self.history_size - 1
    %      |bit_counts| is constrained to [0, 32], meaning we can smooth with a
    %    factor up to 2^26. We use Q9.
         bit_count = (self.bit_counts(i + 1) * 2^9);

    %  Update |mean_bit_counts| only when far-end signal has something to
    %  contribute. If |far_bit_counts| is zero the far-end signal is weak and
    %  we likely have a poor echo condition, hence don't update.
        if (self.farend.far_bit_counts(i + 1) > 0) 
    %  Make number of right shifts piecewise linear w.r.t. |far_bit_counts|.
          shifts = param.kShiftsAtZero;
          shifts = shifts - (param.kShiftsLinearSlope * self.farend.far_bit_counts(i + 1)) / 2^4;
          self.mean_bit_counts(i + 1) = WebRtc_MeanEstimatorFix(bit_count, shifts, self.mean_bit_counts(i + 1));
        end
      end
%      plot(self.bit_counts);
%      pause(0.3);
%        Find |candidate_delay|, |value_best_candidate| and |value_worst_candidate|
%   of |mean_bit_counts|.
    for i = 0:self.history_size - 1
        if (self.mean_bit_counts(i + 1) < value_best_candidate) 
          value_best_candidate = self.mean_bit_counts(i + 1);
          candidate_delay = i;
        end
        if (self.mean_bit_counts(i + 1) > value_worst_candidate) 
          value_worst_candidate = self.mean_bit_counts(i + 1);
        end
   end
   valley_depth = value_worst_candidate - value_best_candidate;
%        Update |minimum_probability|.
   if ((self.minimum_probability > param.kProbabilityLowerLimit) &&...
      (valley_depth > param.kProbabilityMinSpread)) 
%     // The "hard" threshold can't be lower than 17 (in Q9).
%     // The valley in the curve also has to be distinct, i.e., the
%     // difference between |value_worst_candidate| and |value_best_candidate| has
%     // to be large enough.
        threshold = value_best_candidate + param.kProbabilityOffset;
        if (threshold < param.kProbabilityLowerLimit) 
          threshold = param.kProbabilityLowerLimit;
        end
        if (self.minimum_probability > threshold) 
          self.minimum_probability = threshold;
        end
   end
    
   self.last_delay_probability = self.last_delay_probability + 1;
   
   valid_candidate = ((valley_depth > param.kProbabilityOffset) &&...
      ((value_best_candidate < self.minimum_probability) ||...
          (value_best_candidate < self.last_delay_probability)));
      
%       non_stationary_farend =...
%       std::any_of(self.farend.far_bit_counts,
%                   self.farend.far_bit_counts + self.history_size,
%                   [](int a) { return a > 0; });
      non_stationary_farend = 1;%debug
      
    if (non_stationary_farend) 
%     // Only update the validation statistics when the farend is nonstationary
%     // as the underlying estimates are otherwise frozen.
        self = UpdateRobustValidationStatistics(self, candidate_delay, valley_depth,...
                                     value_best_candidate, param);
    end
    
    if (self.robust_validation_enabled) 
        is_histogram_valid = HistogramBasedValidation(self, candidate_delay);
        valid_candidate = RobustValidation(self, candidate_delay, valid_candidate,...
                                       is_histogram_valid);
    end
    
    if (non_stationary_farend && valid_candidate) 
        if (candidate_delay ~= self.last_delay) 
              if(self.histogram(candidate_delay + 1) > param.kLastHistogramMax)
                  self.last_delay_histogram = param.kLastHistogramMax;
              else
                  self.last_delay_histogram = self.histogram(candidate_delay + 1);
              end
    %       // Adjust the histogram if we made a change to |last_delay|, though it was
    %       // not the most likely one according to the histogram.
              if (self.histogram(candidate_delay + 1) <...
                  self.histogram(self.compare_delay + 1))
                self.histogram(self.compare_delay + 1) = self.histogram(candidate_delay + 1);
              end
       end
        self.last_delay = candidate_delay;
        if (value_best_candidate < self.last_delay_probability) 
          self.last_delay_probability = value_best_candidate;
        end
        self.compare_delay = self.last_delay;
    end

      delay_est = self.last_delay;
end