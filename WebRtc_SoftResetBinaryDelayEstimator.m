function [y, self] = WebRtc_SoftResetBinaryDelayEstimator(self, delay_shift) 
%   lookahead = 0;
%   RTC_DCHECK(self);
  lookahead = self.lookahead;
  self.lookahead = self.lookahead - delay_shift;
  if (self.lookahead < 0) 
    self.lookahead = 0;
  end
  if (self.lookahead > self.near_history_size - 1) 
    self.lookahead = self.near_history_size - 1;
  end
  y = lookahead - self.lookahead;
end
