class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #before_filter :cors_set_access_control_headers  
  
  #def cors_set_access_control_headers
  #  response.headers['Access-Control-Allow-Origin'] = '*'
  #  response.headers['Access-Control-Request-Method'] = '*'
  #  response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  #  response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email'
  #  response.headers['Access-Control-Max-Age'] = "1728000"
  #  puts "cors set"
  #end
  
  
end
