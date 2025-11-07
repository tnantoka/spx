# frozen_string_literal: true

module Spx
  class Runner
    HOST = "localhost"
    MESSAGES = {
      run_code: "/run-code",
      start_recording: "/start-recording",
      stop_recording: "/stop-recording",
      save_recording: "/save-recording",
      test_callback: "/test-callback",
      record_callback: "/record-callback"
    }.freeze
    TIMES = {
      test_timeout: 1,
      stop_margin: 1
    }.freeze

    def initialize(port, token, callback_port)
      @port = port
      @token = token
      @callback_port = callback_port
    end

    def test_connection # rubocop:disable Metrics/MethodLength
      connected = false

      run_with_callback("", MESSAGES[:test_callback]) do
        connected = true
      end

      Timeout.timeout(TIMES[:test_timeout]) do
        loop do
          sleep 0.1
          break if connected
        end
      end

      true
    rescue Timeout::Error
      false
    end

    def play(code)
      send_message(MESSAGES[:run_code], code)
    end

    def record(code, output_file) # rubocop:disable Metrics/MethodLength
      start_recording

      recorded = false

      run_with_callback(code, MESSAGES[:record_callback]) do
        sleep TIMES[:stop_margin]
        stop_recording
        save_recording(output_file)
        recorded = true
      end

      loop do
        sleep 0.1
        break if recorded
      end
    end

    private

    def start_recording
      send_message(MESSAGES[:start_recording])
    end

    def stop_recording
      send_message(MESSAGES[:stop_recording])
    end

    def save_recording(file_path)
      send_message(MESSAGES[:save_recording], file_path)
    end

    def send_message(type, body = nil)
      prepared = OSC::Message.new(type, @token, body)
      client.send(prepared)
    end

    def client
      @client ||= OSC::Client.new(HOST, @port)
    end

    def code_with_callback(code, type)
      [
        code,
        "osc_send 'localhost', 3333, '#{type}'"
      ].join("\n")
    end

    def run_with_callback(code, type, &callback)
      server.add_method(type.dup) do
        callback.call
      end

      send_message(
        MESSAGES[:run_code],
        code_with_callback(code, type)
      )
    end

    def server
      @server ||= OSC::Server.new(@callback_port).tap do |server|
        Thread.new { server.run }
      end
    end
  end
end
