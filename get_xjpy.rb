# coding: utf-8

require 'open-uri'
require 'nokogiri'

# 2016/01/17 「I'm not a robot」「わたしはロボットではありません」というメッセージとともに
#   表示される画像のチェックボックスをクリックしないと先に進まないことがあった
# 1 通貨(currency)は何円か?
def get_xjpy_from_google(currency)
  return @rate[currency] if not @rate.nil? and @rate[currency]
  @rate = {}

  url = "https://www.google.com/finance/converter?a=1&from=#{currency}&to=JPY"

  if currency == "JPY"
    @rate[currency] = 1.0
  else
    f = open(url).read
    /<span class=bld>(\d+(\.\d+)?) JPY<\/span>/.match(f)

    unless $1
      printf("Googleからデータを取得できませんでした\n")
      exit(1)
    end
  end
  @rate[currency] = $1.to_f

  return @rate[currency]
end

# 151101　investing.com のレートは、週末には更新されないようである。
# currency = eur, usd
def get_xjpy_from_investing(currency)
  return @rate_i[currency] if not @rate_i.nil? and @rate_i[currency]
  @rate_i = {}

  url = "http://www.investing.com/currencies/#{currency}-jpy"

  if currency == "JPY"
    @rate_i[currency] = 1.0
  else
    doc = open(url).read

    /<span class=\"arial_26 inlineblock pid-\d-last\" id=\"last_last\" dir=\"ltr\">(\d+(\.\d+)?)<\/span>/.match(doc)

    unless $1
      printf("Investing.com からデータを取得できませんでした\n")
      exit(1)
    end
    @rate_i[currency] = $1.to_f
  end

  return @rate_i[currency]
end

def get_xjpy_from_yahoo(currency)
  # スクレイピング先のURL
  return @rate_y[currency] if not @rate_y.nil? and @rate_y[currency]
  @rate_y = {}

  if currency == "JPY"
    @rate_y[currency] = 1.0
  else
    url = "http://stocks.finance.yahoo.co.jp/stocks/detail/?code=#{currency}jpy=x"

    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    # htmlをパース(解析)してオブジェクトを生成
    doc = Nokogiri::HTML.parse(html, nil, charset)

    # タイトルを表示
    @rate_y[currency] = doc.xpath('//td[@class="stoksPrice"]').text.to_f
  end

  unless @rate_y[currency]
    printf("stocks.finance.yahoo.co.jpからデータを取得できませんでした\n")
    exit(1)
  end

  @rate_y[currency]
end

# v1 と v2 の比が (1.0 + ratio) に収まる場合 true
def in_range(v1, v2, ratio)
  return (v1 > v2 * ratio or v2 > v1 * ratio)
end

# 通貨 X から jpy に変換, 範囲は 0.1 %
def get_xjpy(cur, ratio = 0.001)
  xjpy_g = get_xjpy_from_google(cur)
  xjpy_i = get_xjpy_from_investing(cur)
  xjpy_y = get_xjpy_from_yahoo(cur)

  xjpy_ave = (xjpy_g + xjpy_i + xjpy_y) / 3.0

  if in_range(xjpy_ave, xjpy_g, ratio) and in_range(xjpy_ave, xjpy_i, ratio) and in_range(xjpy_ave, xjpy_y, ratio)
    return xjpy_g
  else
    puts "範囲エラー #{xjpy_g} #{xjpy_i} #{xjpy_y}"
    exit(1)
  end
end
