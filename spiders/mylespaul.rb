require "open-uri"
require "nokogiri"
require "date"
require "cgi"

class MyLesPaul
  def initialize(domain)
  end

  def forums
    doc = Nokogiri::HTML(open("http://www.mylespaul.com/forums"))

    doc.css(".alt1Active a").map do |link|
      { 'forum_name' => link.text,
        'forum_id' => link.attr("href").split("/")[-1],
        'description' => link.parent.parent.css(".smallfont")[1].text
      } if link and link.parent.parent.css(".smallfont")[1]
    end.compact
  end

  def topics(id, page = 1)
    doc = Nokogiri::HTML(open("http://www.mylespaul.com/forums/#{id}"))

    { 'total_topic_num' => 1000,
      'forum_name' => id,
      'topics' =>
      doc.css("#threadslist .alt1 a").map do |topic|
        { 'topic_id' => topic.attr("href").split("/")[-2..-1].join("--"),
          'topic_title' => topic.text,
          'topic_author_name' => topic.parent.parent.css(".smallfont").last.text,
          'timestamp' => topic.parent.parent.parent.css(".smallfont").last.children.first.text.strip,
          'reply_number' => topic.parent.parent.parent.css(".alt1 a").last.text,
        } if topic.attr("id") && topic.attr("id").include?("thread_title")
      end.compact
    }
  end

  def posts(id, page = 1)
    doc = Nokogiri::HTML(open("http://www.mylespaul.com/forums/#{id.gsub('--', '/')}"))

    { 'forum_id' => id.split("--").first,
      'forum_title' => id.split("--").first.gsub("-", " "),
      'posts' => doc.css(".vbseo_like_postbit").map do |post|
        { 'post_count' => post.css("a strong").first.text,
          'post_author_name' => post.css(".bigusername").text,
          'timestamp' => '',
          'post_content' => process_html(post.css("tr .alt1 div")[1].children.to_html.strip)
        } if post.css("a strong").first
      end.compact
    }
  end

  def process_html(html)
    h = html
      .gsub(/<\/?(table|td|tr|th)(.*)(.*?)>/, '')
      .gsub(/<div(.*?)>Quote:<\/div>/, '')
      .gsub(/<div style="margin:20px; margin-top:5px; ">/, '<div class="blockquote">')
      .gsub(/<a(.*?)><img(.*?)viewpost(.*?)><\/a>/, '')
      .gsub(/(\s*<br>\s*|\s*<p>\s*<\/p>\s*)+/, "<br>")
      .gsub(/<img src="(.*?)mylespaul.com(.*?)"(.*?)title="(.*?)"? class=(.*?)"?>/, '<strong>\4</strong>')
      .gsub(/^[\s]*/, '')
      .gsub(/^[\s]*$\n/, '')
      .gsub('www.mylespaul.com', 'www.mylespaul2.com')
  end
end