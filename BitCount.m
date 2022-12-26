function val = BitCount(x)
  
%     val =  bitand(x , hex2dec('fff')) * bitand(hex2dec('1001001001001') , 84210842108421); % 0x1f;
%     val = val + bitand((floor(bitand(x , hex2dec('ff000')) / 2^12) * hex2dec('1001001001001')) ,hex2dec('84210842108421')); % 0x1f;
%     val = val + bitand(floor(x / 2^24 * hex2dec('1001001001001')), hex2dec('84210842108421'),'int64'); % 0x1f;
      a = dec2bin(x);
      b = zeros(1,length(a));
      for i = 1:length(a)
        b(i) = str2double(a(i));
      end
      val = sum(b);

end