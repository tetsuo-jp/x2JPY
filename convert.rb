# coding: utf-8

require 'open-uri'

class Convert
  def initialize
    @rate = {}
  end

  def convert(pair)
    from = nil
    to   = nil

    curs = ["AED","AFN","ALL","AMD","ANG","AOA","ARS","AUD","AWG","AZN","BAM","BBD","BDT","BGN","BHD","BIF","BMD","BND","BOB","BRL","BSD","BTC","BTN","BWP","BYR","BZD","CAD","CDF","CHF","CLF","CLP","CNH","CNY","COP","CRC","CUP","CVE","CZK","DEM","DJF","DKK","DOP","DZD","EGP","ERN","ETB","EUR","FIM","FJD","FKP","FRF","GBP","GEL","GHS","GIP","GMD","GNF","GTQ","GYD","HKD","HNL","HRK","HTG","HUF","IDR","IEP","ILS","INR","IQD","IRR","ISK","ITL","JMD","JOD","JPY","KES","KGS","KHR","KMF","KPW","KRW","KWD","KYD","KZT","LAK","LBP","LKR","LRD","LSL","LTL","LVL","LYD","MAD","MDL","MGA","MKD","MMK","MNT","MOP","MRO","MUR","MVR","MWK","MXN","MYR","MZN","NAD","NGN","NIO","NOK","NPR","NZD","OMR","PAB","PEN","PGK","PHP","PKG","PKR","PLN","PYG","QAR","RON","RSD","RUB","RWF","SAR","SBD","SCR","SDG","SEK","SGD","SHP","SKK","SLL","SOS","SRD","STD","SVC","SYP","SZL","THB","TJS","TMT","TND","TOP","TRY","TTD","TWD","TZS","UAH","UGX","USD","UYU","UZS","VEF","VND","VUV","WST","XAF","XCD","XDR","XOF","XPF","YER","ZAR","ZMK","ZMW","ZWL"]

    # pair の例: USD/JPY, USD/JPY
    if /[A-Z]{3}\/[A-Z]{3}/.match(pair)
      from = pair[0..2]
      to   = pair[4..6]
    elsif /[A-Z]{3}[A-Z]{3}/.match(pair)
      from = pair[0..2]
      to   = pair[3..5]
    else
      raise("convert: format error --> #{pair}")
    end

    unless @rate[:"#{from}#{to}"].nil?
      return @rate[:"#{from}#{to}"]
    end

    unless curs.include?(from) and curs.include?(to)
      STDERR.puts "Googleから取得できない通貨が含まれています。#{from}, #{to}"
      exit(1)
    end

    url = "https://www.google.com/finance/converter?a=1&from=#{from}&to=#{to}"
    return 1.0 if from == to

    f = open(url).read
    /<div id=currency_converter_result>1 #{from} = <span class=bld>(\d+(\.\d+)?) #{to}<\/span>/.match(f)

    unless $1
      printf("Googleからデータを取得できませんでした。\n")
      exit(1)
    end
    if $1.to_f <= 0
      printf("1 #{from} が 0 #{$1}に変換され、異常です。\n")
      exit(1)
    end
    @rate[:"#{from}#{to}"] = $1.to_f

    return @rate[:"#{from}#{to}"]
  end
end

# c = Convert.new
# puts c.convert("EURUSD")
# puts c.convert("EURUSD")
