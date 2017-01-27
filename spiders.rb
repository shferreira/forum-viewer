require './spiders/thecomatorium'
require './spiders/tapatalk'
require './spiders/mylespaul'
require './spiders/gearslutz'

class Spider
  def self.for(domain)
    if domain == 'forum.thecomatorium.com'
      TheComatorium.new(domain)
    elsif domain == 'www.mylespaul.com'
      MyLesPaul.new(domain)
    elsif domain == 'www.gearslutz.com'
      Gearslutz.new(domain)
    else
      Tapatalk.new(domain)
    end
  end
end
