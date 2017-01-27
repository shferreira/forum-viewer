require "sinatra"
require './spiders'

## Befores

before do
  @spider = Spider.for(env["REQUEST_PATH"].split("/")[1])
end

## Routes

get '/' do
  erb :index
end

get '/:domain/?' do |domain|
  forums = @spider.forums

  erb :forums, locals: { name: domain, forums: forums }
end

get '/:domain/forum-:forum/?' do |domain, forum|
  topics = @spider.topics(forum, params[:page])

  erb :topics, locals: { topics: topics }
end

get '/:domain/topic-:topic/?' do |domain, topic|
  posts = @spider.posts(topic, params[:page])

  erb :posts, locals: { posts: posts }
end

## Helpers

helpers do
  def ago(time)
    time = Time.strptime(time,'%s') if time.to_i.to_s == time
    diff = Time.now - time
    { seconds: 60, minute: 60, hour: 24, day: 30, month: 12, year: 10000 }.map do |n,r|
      (diff, v = diff.divmod(r)) && "#{v.ceil} #{n}#{'s' if v > 1}" if diff > 0
    end.compact.last + ' ago'
  rescue
    time
  end

  def format(text)
    text
      .gsub(/\r\n?/, "\n")
      .gsub(/\n\n+/, "</p>\n\n<p>")
      .gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')
      .gsub(/\[quote name=(?:&quot;)?(.*?)(?:&quot;)? ?post?=?(?:&quot;)?(.*?)(?:&quot;)?\](.*?)\[\/quote\1?\]/mi, '<blockquote><strong>\1 said:</strong><br>\3</blockquote>')
      .gsub(/\[quote(.*)?\](.*?)\[\/quote\1?\]/mi, '<blockquote>\2</blockquote>')
      .gsub(/\[url=(?:&quot;)?(http|https):\/\/(www\.)?youtube\.com\/watch\?.*v=([a-zA-Z0-9]+).*(?:&quot;)?\](.*?)\[\/url\]/mi, '<iframe class="youtube-player" type="text/html" width="640" height="385" src="http://www.youtube.com/embed/\3" allowfullscreen frameborder="0"></iframe>')
      .gsub(/\[url=(?:&quot;)?(.*?)(?:&quot;)?\](.*?)\[\/url\]/mi, '<a href="\1" rel="nofollow">\2</a>')
      .gsub(/\[url\](.*?)\[\/url\]/mi, '<a href="\1" rel="nofollow">\1</a>')
      .gsub(/\[img\]([^\[\]].*?)\[\/img\]/im, '<img src="\1" />')
      .gsub(/\[youtube\](.*?)\?v=([\w\d\-]+).*\[\/youtube\]/im, '<iframe class="youtube-player" type="text/html" width="640" height="385" src="http://www.youtube.com/embed/\2" allowfullscreen frameborder="0"></iframe>')
  end
end
