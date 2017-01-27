require "open-uri"
require "nokogiri"

class Gearslutz
  def initialize(domain)
  end

  def forums
    doc = Nokogiri::HTML(open("http://www.gearslutz.com/board"))

    doc.css(".forumBitContainer.postedIn").map do |forum|
      { 'forum_name' => forum.css("a").first.text,
        'forum_id' => forum.css("a").first.attr("href").split("/")[-1],
        'description' => forum.css(".forumDescription").text.strip.split("Moderated by").first
      }
    end
  end

  def topics(id, page = 1)
    page ||= 1
    doc = Nokogiri::HTML(open("http://www.gearslutz.com/board/#{id}#{ "/index" + page + ".html" if page.to_s != "1" }"))

    { 'total_topic_num' => 1000,
      'forum_name' => id.gsub("-", " "),
      'topics' => doc.css("section").map do |thread|
        {
          'topic_id' => thread.css(".title a").first.attr("href").split("/")[-2..-1].join("--"),
          'topic_title' => thread.css(".title a").first.text.strip,
          'topic_author_name' => thread.css(".threadBitUsername").text,
          'reply_number' => thread.css(".replies").text,
          'timestamp' => thread.css(".lastPostInfo").text.strip.split("\n").first
        }
      end
    }
  end

  def posts(id, page = 1)
    id = id.gsub(".html", "-#{page}.html") if page && page.to_s != "1"
    doc = Nokogiri::HTML(open("http://www.gearslutz.com/board/#{id.gsub('--', '/') }"))

    { 'total_post_num' => 1000,
      'topic_title' => "?",
      'forum_title' => id.split("--").first.gsub("-", " "),
      'forum_id' => id.split("--").first,
      'posts' => doc.css("section").map do |post|
        { 'post_author_name' => post.css("a[rel='author']").text,
          'post_content' => post.css("article").text.strip.gsub(/\n+/, "<br>"),
          'post_count' => post.css("a strong").first.text,
          'timestamp' => '',
        } if post.css("a strong").first
      end.compact

    }
  end
end
