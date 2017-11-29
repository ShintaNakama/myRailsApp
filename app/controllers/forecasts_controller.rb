class ForecastsController < ApplicationController
  require 'json'
    def result
      @profile = Profile.find(params[:id])
      # forture_api 186行目
      @result = FortuneAPI::get_result('KSK', 'free001', @profile, nil).get_data
      
      @resultTitle = @result["items"][0]["caption"]
      @resultBody = @result["items"][0]["body"]
    end

end
