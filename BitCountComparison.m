function bit_counts = BitCountComparison(binary_vector, binary_matrix, matrix_size)
       bit_counts = NaN(1, matrix_size);
%      Compare with delayed spectra and store the |bit_counts| for each delay.
       for i = 0:matrix_size - 1
            bit_counts(i + 1) = BitCount(bitand(binary_vector, binary_matrix(i + 1)));
       end
end