function self = WebRtc_SoftResetDelayEstimatorFarend(self,  delay_shift) 
  
    self.binary_farend = WebRtc_SoftResetBinaryDelayEstimatorFarend(self.binary_farend, delay_shift);
 
end