function [y, self] = WebRtc_SoftResetDelayEstimator(self,  delay_shift) 
%   DelayEstimator* self = (DelayEstimator*) handle;
%   RTC_DCHECK(self);
   [y, self.binary_handle] = WebRtc_SoftResetBinaryDelayEstimator(self.binary_handle, delay_shift);
end