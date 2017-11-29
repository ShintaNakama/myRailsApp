class ForecastsController < ApplicationController
  require 'json'
    def result
      File.open("./lib/pre_result_free001.json") {|file|
      @forecasts = JSON.load(file)}
      @icon = @forecasts["info"]["images"]["icon"]
      @icon2 = @forecasts["info"]["images"]["icon_s"]
      @profile = Profile.find(params[:id])
      # forture_api 186行目
      @result = FortuneAPI::get_result('KSK', 'free001', @profile, nil).get_data
      
      @resultTitle = @result["items"][0]["caption"]
      @resultBody = @result["items"][0]["body"]
    end

end
