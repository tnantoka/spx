# frozen_string_literal: true

module Spx
  class LogParser
    def initialize(log_file_path)
      @log_file_path = log_file_path
    end

    def parse
      port = nil
      token = nil

      File.foreach(@log_file_path) do |line|
        token ||= line[/Token:\s+(-?\d+)/, 1]&.to_i
        port ||= line[/:server_port=>(\d+)/, 1]&.to_i

        break if port && token
      end

      { port: port, token: token }
    end
  end
end
