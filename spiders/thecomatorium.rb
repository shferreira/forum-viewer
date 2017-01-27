require "open-uri"
require "nokogiri"

class TheComatorium
  def initialize(domain)
    @cookie = 'coma_member_id=117605; coma_pass_hash=8aa1fc4f7b3f43d9eb83e8527d73ec84; ipsconnect_09e52f12604933b8ce9f7e4c14c098b5=1; coma_session_id=83fc3f9c6e267e9adb20c84b609574a5'
  end

  def forums
    doc = Nokogiri::HTML(open("http://forum.thecomatorium.com/forum", "Cookie" => @cookie))

    doc.css("#board_index .col_c_forum a").map do |link|
      { 'forum_name' => link.text,
        'forum_id' => link.attr("href").split("=").last,
        'description' => link.parent.parent.css(".desc").text
      }
    end
  end

  def topics(id, page = 1)
    doc = Nokogiri::HTML(open("http://forum.thecomatorium.com/forum/index.php?showforum=#{id}&page=#{page}", 'Cookie' => @cookie))

    last = doc.css("a[rel='last']").first.attr("href").split("=").last.to_i * 20 rescue 20

    { 'total_topic_num' => last,
      'forum_name' => doc.css(".ipsType_pagetitle").text,
      'topics' =>
      doc.css(".__topic").map do |thread|
        views = 0
        { 'topic_id'          => thread.css("a[itemprop='url']").first.attr("href").split("=").last,
          'topic_title'       => thread.css("a[itemprop='url'] span[itemprop='name']").text,
          'topic_author_name' => thread.css(".fn.name").first.text,
          'timestamp'         => thread.css("span[itemprop='dateCreated']").text,
          'reply_number'      => thread.css("[itemprop='interactionCount']").attr("content").to_s.split(":").last
        }
    end }
  end

  def posts(post, page = 1)
    doc = Nokogiri::HTML(open("http://forum.thecomatorium.com/forum/index.php?showtopic=#{post}&page=#{page}", 'Cookie' => @cookie))

    title = doc.css("h1[itemprop='name']").text
    forum = doc.css("ol.breadcrumb.top li").last.text.gsub('→', '').strip
    forumid = doc.css("ol.breadcrumb.top li a").last.attr("href").split("=").last
    active = doc.css(".pagination li.active").last.text.to_i rescue 1
    last = doc.css("a[rel='last']").first.attr("href").split("=").last.to_i * 20 rescue [ 10, active * 20 - 20 ].max

    { 'total_post_num' => last,
      'topic_title' => title,
      'forum_title' => forum,
      'forum_id' => forumid,
      'posts' => doc.css(".hentry").map do |post|
        { 'post_author_name' => post.css(".vcard").text,
          'post_content' => process_html(post.css(".entry-content").children.to_html),
          'timestamp' => Time.new(post.css("abbr").first.attr("title"))
        }
      end
    }
  end

  def process_html(html)
    html
      .gsub(/(\s*<br ?\/?>\s*|\s*<p>\s*<\/p>\s*)+/, "<br>")
      .gsub(/<img src="(.*?)thecomatorium.com(.*?)"(.*?)alt="(.*?)"?(.*?)"?>/, '<strong>\5</strong>')
  end
end
