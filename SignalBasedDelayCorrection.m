function delay_correction = SignalBasedDelayCorrection(self, param) 
   delay_correction = 0;
%    last_delay = -2;
%   RTC_DCHECK(self);
% #if !defined(WEBRTC_ANDROID)
%   // On desktops, turn on correction after |kDelayCorrectionStart| frames.  This
%   // is to let the delay estimation get a chance to converge.  Also, if the
%   // playout audio volume is low (or even muted) the delay estimation can return
%   // a very large delay, which will break the AEC if it is applied.
%   if (self->frame_count < kDelayCorrectionStart) {
%     self->data_dumper->DumpRaw("aec_da_reported_delay", 1, &last_delay);
%     return 0;
%   }
% #endif

%   // 1. Check for non-negative delay estimate.  Note that the estimates we get
%   //    from the delay estimation are not compensated for lookahead.  Hence, a
%   //    negative |last_delay| is an invalid one.
%   // 2. Verify that there is a delay change.  In addition, only allow a change
%   //    if the delay is outside a certain region taking the AEC filter length
%   //    into account.
%   // TODO(bjornv): Investigate if we can remove the non-zero delay change check.
%   // 3. Only allow delay correction if the delay estimation quality exceeds
%   //    |delay_quality_threshold|.
%   // 4. Finally, verify that the proposed |delay_correction| is feasible by
%   //    comparing with the size of the far-end buffer.
  last_delay = WebRtc_last_delay(self.delay_estimator);
%   self->data_dumper->DumpRaw("aec_da_reported_delay", 1, &last_delay);
  if ((last_delay >= 0) && (last_delay ~= self.previous_delay) &&...
      (WebRtc_last_delay_quality(self.delay_estimator, param) >...
       self.delay_quality_threshold))
         delay = last_delay - WebRtc_lookahead(self.delay_estimator);
%     // Allow for a slack in the actual delay, defined by a |lower_bound| and an
%     // |upper_bound|.  The adaptive echo cancellation filter is currently
%     // |num_partitions| (of 64 samples) long.  If the delay estimate is negative
%     // or at least 3/4 of the filter length we open up for correction.
    lower_bound = 0;
    upper_bound = self.num_partitions * 3 / 4;
    do_correction = delay <= lower_bound || delay > upper_bound;
    if (do_correction == 1) 
%       available_read = self.farend_block_buffer_.Size();
        available_read = 7777;
%       // With |shift_offset| we gradually rely on the delay estimates.  For
%       // positive delays we reduce the correction by |shift_offset| to lower the
%       // risk of pushing the AEC into a non causal state.  For negative delays
%       // we rely on the values up to a rounding error, hence compensate by 1
%       // element to make sure to push the delay into the causal region.
      delay_correction = delay_correction - delay;
      if(delay > self.shift_offset)
          tmp = self.shift_offset;
      else
          tmp = 1;
      end
      delay_correction = delay_correction + tmp;
      self.shift_offset = self.shift_offset - 1;
      self.shift_offset = max(1, self.shift_offset);
%       if (delay_correction > available_read - self->mult - 1) 
      if (delay_correction > available_read - 1 - 1) 
%         // There is not enough data in the buffer to perform this shift.  Hence,
%         // we do not rely on the delay estimate and do nothing.
        delay_correction = 0;
      else 
        self.previous_delay = last_delay;
        self.delay_correction_count = self.delay_correction_count + 1;
      end
    end
  end
%   // Update the |delay_quality_threshold| once we have our first delay
%   // correction.
  if (self.delay_correction_count > 0) 
    delay_quality = WebRtc_last_delay_quality(self.delay_estimator);
    delay_quality = min(param.kDelayQualityThresholdMax, delay_quality);
    self.delay_quality_threshold = min(delay_quality, self.delay_quality_threshold);
  end
%   self->data_dumper->DumpRaw("aec_da_delay_correction", 1, &delay_correction);

end