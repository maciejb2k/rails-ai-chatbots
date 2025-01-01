module ApplicationHelper
  def add_url_protocol(url)
    unless url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      url = "https://#{url}"
    end
    
    url
  end
end
