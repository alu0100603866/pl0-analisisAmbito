require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-github'
use OmniAuth::Builder do
 # config = YAML.load_file 'config/config.yml'
 # provider :google_oauth2, config['identifier'], config['secret']
  provider :google_oauth2, '1066988301696-ibvf979d468t3ril0ee6n66oj4l1uuvg.apps.googleusercontent.com', 'pH5p8_z66TOaALv4wuHujOUo'
#  config = YAML.load_file 'config/config_github.yml'
 # provider :github, config['identifier'], config['secret']
  provider :github, '0cbd6fa60d7ed5741f3b', '69ca444787c084453640cb1e707361a583ee5bbb'
end

get '/auth/:name/callback' do
  session[:auth] = @auth = request.env['omniauth.auth']
  session[:name] = @auth['info'].name
  session[:image] = @auth['info'].image
  puts "params = #{params}"
  puts "@auth.class = #{@auth.class}"
  puts "@auth info = #{@auth['info']}"
  puts "@auth info class = #{@auth['info'].class}"
  puts "@auth info name = #{@auth['info'].name}"
  puts "@auth info email = #{@auth['info'].email}"
  #puts "-------------@auth----------------------------------"
  #PP.pp @auth
  #puts "*************@auth.methods*****************"
  #PP.pp @auth.methods.sort
  flash[:notice] = 
        %Q{<div class="success">Authenticated as #{@auth['info'].name}.</div>}
  redirect '/'
end

get '/auth/failure' do
  flash[:notice] = params[:message] 
  redirect '/'
end