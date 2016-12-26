require 'gemmyrb'
module SinatraSockets
end
Gem.find_files("sinatra_sockets/**/*.rb").each &method(:require)
