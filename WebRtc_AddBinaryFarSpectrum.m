function handle = WebRtc_AddBinaryFarSpectrum(handle, binary_far_spectrum) 

    handle.binary_far_history(2:end) =  handle.binary_far_history(1:end - 1);        
    handle.binary_far_history(1) = binary_far_spectrum;

    handle.far_bit_counts(2:end) =  handle.far_bit_counts(1:end - 1);        
    handle.far_bit_counts(1) = BitCount(binary_far_spectrum);
    
end