function [last_delay, self] = WebRtc_DelayEstimatorProcessFloat(self,...
                                                near_spectrum,...
                                                param) 
%   DelayEstimator* self = (DelayEstimator*) handle;
%   uint32_t binary_spectrum = 0;
% 
%   if (self == NULL) {
%     return -1;
%   }
%   if (near_spectrum == NULL) {
%     // Empty near end spectrum.
%     return -1;
%   }
%   if (spectrum_size != self->spectrum_size) {
% %     // Data sizes don't match.
%     return -1;
%   }

%   // Get binary spectrum.
  [binary_spectrum, self.mean_near_spectrum, self.near_spectrum_initialized] = BinarySpectrumFloat(near_spectrum, self.mean_near_spectrum,...
                                        self.near_spectrum_initialized, param);

  [last_delay, self.binary_handle] = WebRtc_ProcessBinarySpectrum(self.binary_handle, binary_spectrum, param);
end