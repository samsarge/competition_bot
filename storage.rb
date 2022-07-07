require 'yaml'

class Storage
  FILE_NAME = 'storage.yml'.freeze

  attr_reader :data

  def initialize
    @data = YAML.load(File.read(FILE_NAME)) || {}
  end

  def add(win_text:)
    @data[:win_text] ? @data[:win_text] << win_text : @data[:win_text] = [win_text]
    @data[:win_number] ? (@data[:win_number] = @data[:win_number] + 1) : @data[:win_number] = 1

    File.open(FILE_NAME, "w") { |file| file.write(@data.to_yaml) }

    puts "Saved attempt number #{@data[:win_number]}"
  end
end
