require 'gemmy'

module SinatraSockets
  def self.generate(dest)
    server_skeleton_folder_path = Gem.find_files("server_skeleton")[0]
    `cp -r #{server_skeleton_folder_path} #{dest}`
    puts "done"
    puts "Generated directory:"
    puts `tree #{dest}/server_skeleton`
  end
end
