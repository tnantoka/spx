# frozen_string_literal: true

module Spx
  class CLI < Thor
    class << self
      def shared_options
        method_option :sonic_pi_log, aliases: "-l", desc: "Log file to parse port number and token",
                                     default: "~/.sonic-pi/log/spider.log"
        method_option :callback_port, aliases: "-p", desc: "UDP port to receive messages from Sonic Pi", default: "3333"
      end
    end

    desc "test-connection", "Test connection to Sonic Pi"
    shared_options
    def test_connection
      runner.test_connection.tap do |connected|
        say connected ? "OK" : "NG"
      end
    end

    desc "play SOURCE", "Play a Sonic Pi file"
    shared_options
    def play(file)
      unless runner.test_connection
        say "Cannot connect to Sonic Pi"
        return false
      end

      runner.play(File.read(file))
    end

    desc "record SOURCE", "Record a Sonic Pi session to a file"
    shared_options
    method_option :output, aliases: "-o", desc: "Output file", default: "./output.wav"
    def record(file)
      unless runner.test_connection
        say "Cannot connect to Sonic Pi"
        return false
      end

      runner.record(
        File.read(file),
        File.expand_path(options[:output])
      )
    end

    desc "version", "Show version"
    def version
      say Spx::VERSION
    end

    private

    def runner
      @runner ||= begin
        parser = LogParser.new(File.expand_path(options[:sonic_pi_log]))
        port, token = parser.parse.values_at(:port, :token)
        Runner.new(port, token, options[:callback_port].to_i)
      end
    end
  end
end
