require "xmlrpc/client"

class Tapatalk
  def initialize(domain)
    @domain = domain
  end

  def forums
    rpc(:get_forum, true)
  end

  def topics(id, page = 1)
    offset = ([ 1, page.to_i ].max - 1) * 20

    rpc(:get_topic, id.to_s, offset, offset + 19)
  end

  def posts(id, page = 1)
    offset = ([1, page.to_i].max - 1) * 20

    rpc(:get_thread, id.to_s, offset, offset + 19, false)
  end

  def rpc(command, *args)
    domain, *path = @domain.split('--')
    @client = XMLRPC::Client.new(domain, '/' + path.join('/') + "/mobiquo/mobiquo.php", 80)
    @client.http_header_extra = { "accept-encoding" => "identity" }
    @client.cookie = @session if @session
    @client.call(command, *args)
  end
end
