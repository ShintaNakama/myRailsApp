# encoding: utf-8

class Helpers
  def self.post_request(url, basic_user, basic_pass, post_data)
    url_object = URI.parse(url)
    request = Net::HTTP::Post.new(url_object.path)
    request.basic_auth basic_user, basic_pass
    request.set_form_data(post_data)
    http = Net::HTTP.new(url_object.host, url_object.port)
    http.open_timeout = 3
    http.read_timeout = 3
    if url_object.port == 443
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    return http.start { |http| http.request(request) }
  end
end