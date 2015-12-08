require 'twitter'
require 'yaml'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = 'IrCxPhOyEuE5ayk5wyGegEOH8'
  config.consumer_secret     = 'z3MWJbQ7BbW5QFOltvHX3owNZUQoU9rzmS1GmNjGxc7xgKrsio'
  config.access_token        = '22286566-yvQKhjd5Fr67BpxeLPrTYvrg4vMGS88ddhQgxBGMM'
  config.access_token_secret = 'BRCkzo6XzvUztRbxKhsYKj91fCf97Kbup8RPom9oN4tpC'
end

# Monkey-patch HTTP::URI; https://github.com/sferik/twitter/issues/709                                                                                                                                                                              
class HTTP::URI                                                                                                                                                                                         
  def port                                                                                                                                                                                              
    443 if self.https?                                                                                                                                                                                  
  end                                                                                                                                                                                                   
end

def twitter_test(client)
  all_tweets = get_tweets(client)
  total_word_count = get_word_count(all_tweets)
  filtered_tweets = remove_stop_words(all_tweets)
  identify_most_common_words(filtered_tweets)
  puts "TOTAL WORD COUNT: #{total_word_count}"
  puts "WORD COUNT AFTER FILTER: #{filtered_tweets.length}"
end

def get_tweets(client)
  all_tweets = Array.new
  end_time = Time.now + 15
  client.sample do |status|
    if status.is_a?(Twitter::Tweet) && status.user.lang == "en"
      parsed_tweet = parse_tweet(status.text)
      all_tweets.push(parsed_tweet)
    end
    break if Time.now >= end_time
  end
  all_tweets.flatten.compact
end

def parse_tweet(text)
  text.gsub(/[^0-9A-Za-z' #@]/, '').downcase.split(' ')
end

def get_word_count(all_tweets)
  all_tweets.length
end

def remove_stop_words(all_tweets)
  stop_words = YAML.load_file('stop_words.yml')
  puts "word count before deleting: #{all_tweets.length}"
  all_tweets.delete_if { |word| stop_words["english"].include?(word) }
  puts "word count after deleting: #{all_tweets.length}"
  all_tweets
end

def identify_most_common_words(filtered_tweets)
  filtered_tweets.sort
  frequencies = filtered_tweets.each_with_object(Hash.new(0)) { |word,count| count[word] += 1 }.sort_by { |word, count| count }.reverse!.take(10)
  p frequencies
end

twitter_test(client)