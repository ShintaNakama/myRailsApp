# encoding: utf-8

require 'open-uri'
class FortuneAPIMenus
  def initialize(data)
    @data = data.dup
  end
  def get_data
    return @data
  end

  # 人気順に並び変える
  def sort_by_ranking!
    # select menu, count(*) as count from histories group by menu order by count desc;
    menu_ranking = History.group(:itemcd).order('count_itemcd desc').count(:itemcd)
    @data.sort! {
      |a, b|
      if menu_ranking[a['itemcd']].to_i < menu_ranking[b['itemcd']].to_i
        1
      elsif menu_ranking[a['itemcd']].to_i > menu_ranking[b['itemcd']].to_i
        -1
      else
        0
      end
    }
  end
  # 入荷順
  def sort_by_opening_date!
    @data.sort! {
      |a, b|
      if a['opened_at'] < b['opened_at']
        1
      elsif a['opened_at'] > b['opened_at']
        -1
      else
        0
      end
    }
  end

  # 新着のみを抽出
  def extract_new!
    @data.select! {
      |menu|
      (DateTime.now - DateTime.rfc3339(menu['opened_at'])) < Rails.configuration.x.new_menus_max_age_in_days
    }
  end
  # 無料のみを抽出
  def extract_free!
    return @data.select! {
      |menu|
      menu['android']['price'] == 0
    }
  end
  # 有料のみを抽出
  def extract_non_free!
    return @data.select! {
      |menu|
      menu['android']['price'] > 0
    }
  end
  # 検索
  def search!(query)
    re = Regexp.new(Regexp.quote(query))
    return @data.select! {
      |menu|
      menu['name'].match(re) || menu['caption'].match(re)
    }
  end

  # staticの方がよかった。。。
  def group_by_category
    return @data.group_by {
      |menu|
      menu['category']
    }
  end
  # staticの方がよかった。。。
  def mk_itemcd2menu_title
    return Hash[
      @data.map {
        |menu|
        [menu['itemcd'], menu['name']]
      }
    ]
  end
  # staticの方がよかった。。。
  def get_by_itemcd(itemcd)
    return @data.find {
      |menu|
      menu['itemcd'] == itemcd
    }
  end
  # staticの方がよかった。。。
  # resultの中のおすすめにはオープニングデートが記載されていないので、アップデート時に未公開のものをフィルターしておいている@dateで積集合を作ります
  def get_recommendations_for_result(result)
     return (result.get_recommendation_itemcds & @data.map { |menu| menu['itemcd'] })
  end
end

class FortuneAPIPreresult
  def initialize(data)
    @data = data.dup
  end
  def get_data
    return @data
  end
  # Fortune API-related helpers # TODO: remove IMO :p
  def get_price
    return @data['android']['price']
  end
  def get_persons
    return @data['person']
  end
  def get_name
    return @data['name']
  end
  def get_category
    return @data['category']
  end
  def check_if_new
    return (DateTime.now - DateTime.rfc3339(@data['opened_at'])) < Rails.configuration.x.new_menus_max_age_in_days
  end
  def mk_subitemcd2menu_title
    return Hash[
      @data['items'].map {
        |submenu|
        [submenu['sub_menu_key'], submenu['caption']]
      }
    ]
  end
end

class FortuneAPIResult
  def initialize(data)
    @data = data.dup
  end
  def get_data
    return @data
  end
  def get_recommendation_itemcds
    return @data['recommends'].map {
      |recommendation|
      recommendation['itemcd']
    }
  end
  def get_index_by_subitemcd(subitemcd)
    return @data['items'].find_index {
      |subresult|
      subresult['sub_menu_key'] == subitemcd
    }
  end
end

class FortuneAPI
  @@menu_json = Hash.new

  def self.get_menus(app)
    if !@@menu_json[app] # TODO: test how often this happens in production mode
      begin
        response_body = open("#{Rails.configuration.x.fortune_api_url}#{app}/contents_info",
          :http_basic_authentication=>[Rails.configuration.x.fortune_api_user, Rails.configuration.x.fortune_api_pass]).read
      rescue
        raise ActiveRecord::RecordNotFound
      end
      @@menu_json[app] = JSON.parse(response_body)
      @@menu_json[app]['info'].select! { # 未公開のメニューを削る
        |menu|
        DateTime.rfc3339(menu['opened_at']) < DateTime.now
      }
    end
    return FortuneAPIMenus.new(@@menu_json[app]['info'])
  end

  def self.get_preresult(app, itemcd)
    begin
      response_body = open("#{Rails.configuration.x.fortune_api_url}#{app}/#{itemcd}/preresult",
        :http_basic_authentication=>[Rails.configuration.x.fortune_api_user, Rails.configuration.x.fortune_api_pass]).read
    rescue
      raise ActiveRecord::RecordNotFound
    end
    json = JSON.parse(response_body)
    return FortuneAPIPreresult.new(json['info'])
  end

  def self.get_result(app, itemcd, this_person, that_person)
    post_data = {
      'utf8' => '%E2%9C%93',
      #'name' => this_person.name, # TODO: 必要？
      'birthday' => this_person.birthDay.strftime('%Y-%m-%d'),
      'gender' => this_person.sex == 'woman' ? 'F' : 'M',
      'first_name_kana' => this_person.firstNameKana,
      'last_name_kana' => this_person.lastNameKana
    }
    if that_person
      # post_data['target_name'] = that_person.name # TODO: 必要？
      post_data['target_birthday'] = that_person.birthday.strftime('%Y-%m-%d')
      post_data['target_gender'] = that_person.gender == 'female' ? 'F' : 'M'
    end
    begin
      response = Helpers::post_request(
        "#{Rails.configuration.x.fortune_api_url}#{app}/#{itemcd}/result", # URL
        Rails.configuration.x.fortune_api_user, # user
        Rails.configuration.x.fortune_api_pass, # pass
        post_data # POST data
      )
    rescue
      raise ActiveRecord::RecordNotFound
    end

    json = JSON.parse(response.body)

    return FortuneAPIResult.new(json['result'])
  end
end
