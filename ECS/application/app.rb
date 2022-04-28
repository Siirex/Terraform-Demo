
# Trả về response là "MESSAGE"
class App < Sinatra::Base
    get "/" do
      ENV.fetch("MESSAGE", "Default.")
    end
end
