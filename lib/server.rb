require 'config/environment'

get "/:name" do
  haml params[:name].intern
end

get "/:name.css" do
  content_type 'text/css', :charset => 'utf-8'
  sass params[:name].intern
end