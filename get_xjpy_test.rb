# coding: utf-8

require_relative 'get_xjpy'

['eur', 'usd'].each do|cur|
  puts("1 #{cur} @ google = #{get_xjpy_from_google(cur)}")
  puts("1 #{cur} @ investing = #{get_xjpy_from_investing(cur)}")
  puts("1 #{cur} @ yahoo = #{get_xjpy_from_yahoo(cur)}")
  puts("1 #{cur} = #{get_xjpy(cur)}")
end

# printf("google=    %f\n", get_jpy_from_google('eur'))
# printf("investing= %f\n", get_eurjpy_from_investing)
# printf("yahoo=     %f\n", get_eurjpy_from_yahoo)

# printf("google\tinvestingt\tyahoo:\t%f\t%f\t%f\n",
# printf("%f\t%f\t%f\t",
#        get_jpy_from_google('eur'), get_eurjpy_from_investing, get_eurjpy_from_yahoo)
