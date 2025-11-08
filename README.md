# Spx: Sonic Pi eXecutor

Spx is a CLI tool to play or record Sonic Pi code by using Sonic Pi's built-in OSC server.

## Requirements

- [Sonic Pi](https://github.com/sonic-pi-net/sonic-pi) (version 4.5.0 or later)
- Ruby

## Usage

```bash
# Help
gem exec spx

# Test connection to Sonic Pi
gem exec spx test_connection

# Play Sonic Pi code
gem exec spx play path/to/sonic-pi-code.rb

# Record Sonic Pi code
gem exec spx record path/to/sonic-pi-code.rb -o path/to/output.wav
```

If `gem exec` is not available, you can use the following command instead:

```bash
gem install -g spx
spx
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgements

- https://github.com/sonic-pi-net/sonic-pi
- https://rubygems.org/gems/sonic-pi-cli4
