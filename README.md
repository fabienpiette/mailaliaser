<div align="center">
  <img src="mailaliasers_logo.png" alt="Mailaliaser Logo" width="200" height="200">
  
  # Mailaliaser
  
  [![CI](https://github.com/fabienpiette/mailaliaser/workflows/CI/badge.svg)](https://github.com/fabienpiette/mailaliaser/actions)
  [![Gem Version](https://badge.fury.io/rb/mailaliaser.svg)](https://badge.fury.io/rb/mailaliaser)
</div>

A Ruby gem for generating unique email aliases with timestamp-based suffixes. Perfect for testing, temporary accounts, service sign-ups, or organizing email workflows with automatically generated unique variations.

## Features

- **Unique Generation**: Creates email aliases with timestamp-based suffixes to ensure uniqueness
- **Flexible Configuration**: Customize local parts, domains, and number of emails generated
- **CLI & Library**: Use from command line or integrate into your Ruby applications
- **Clipboard Integration**: Optionally copy generated emails to system clipboard (graceful fallback if unavailable)
- **Cross-Platform**: Works on Linux, macOS, and Windows
- **Multiple Output Formats**: Single email or semicolon-separated list for multiple emails

## Installation

### System Installation

```bash
gem install mailaliaser
```

### Bundler

Add this line to your application's Gemfile:

```ruby
gem 'mailaliaser'
```

And then execute:
```bash
bundle install
```

### Optional: Clipboard Support

For clipboard functionality, install system dependencies:

**Ubuntu/Debian:**
```bash
sudo apt-get install xsel
# or for Wayland
sudo apt-get install wl-clipboard
```

**macOS:**
```bash
# Clipboard support included by default
```

**Windows:**
```bash
# Clipboard support included by default
```

## Usage

### Command Line Interface

#### Basic Usage
```bash
# Generate a single email alias
mailaliaser -l myname -d example.com
# Output: myname+1640995200001@example.com

# Generate multiple aliases
mailaliaser -l user -d test.org -n 5
# Output: user+1640995200001@test.org;user+1640995200002@test.org;...
```

#### Options

| Option | Short | Description | Required | Default |
|--------|-------|-------------|----------|---------|
| `--local-part` | `-l` | Local part of email address | ✅ | - |
| `--domain` | `-d` | Domain part of email address | ✅ | - |
| `--number` | `-n` | Number of emails to generate | ❌ | 1 |
| `--clipboard` | `-c` | Copy to system clipboard | ❌ | true |
| `--quiet` | `-q` | Suppress output to stdout | ❌ | false |
| `--help` | `-h` | Show help message | ❌ | - |
| `--version` | `-v` | Show version information | ❌ | - |

#### Examples

```bash
# Generate 3 aliases for testing
mailaliaser -l testuser -d myapp.com -n 3

# Generate without clipboard (useful in CI/scripts)
mailaliaser -l api -d service.com --no-clipboard

# Generate quietly (only copy to clipboard)
mailaliaser -l silent -d example.org -q

# Generate for multiple services
mailaliaser -l newsletter -d news.com -n 10
```

### Ruby Library

#### Basic Usage

```ruby
require 'mailaliaser'

# Generate a single email
generator = Mailaliaser::Generator.new(
  local_part: 'user',
  domain: 'example.com'
)

email = generator.generate
puts email
# => "user+1640995200001@example.com"
```

#### Advanced Configuration

```ruby
# Generate multiple emails with custom options
generator = Mailaliaser::Generator.new(
  local_part: 'service',
  domain: 'myapp.com',
  number: 5,
  clipboard: false,  # Don't copy to clipboard
  quiet: true        # Don't output to stdout
)

emails = generator.generate
# Returns array of 5 unique email addresses
```

#### Integration Examples

```ruby
# Testing scenarios
RSpec.describe 'User Registration' do
  let(:test_email) do
    Mailaliaser::Generator.new(
      local_part: 'test',
      domain: 'example.com',
      clipboard: false,
      quiet: true
    ).generate
  end

  it 'creates user with unique email' do
    user = User.create(email: test_email)
    expect(user).to be_valid
  end
end

# Service integrations
class NewsletterSignup
  def self.generate_test_email
    Mailaliaser::Generator.new(
      local_part: 'newsletter-test',
      domain: ENV['TEST_DOMAIN'],
      quiet: true
    ).generate
  end
end
```

## Use Cases

- **Software Testing**: Generate unique email addresses for test scenarios
- **Service Sign-ups**: Create temporary emails for service registrations
- **Email Organization**: Generate tagged emails for different purposes
- **Load Testing**: Create multiple unique email addresses for performance testing
- **Development**: Generate test data with guaranteed unique email addresses
- **CI/CD Pipelines**: Automated testing with unique email generation

## Output Format

- **Single email**: Returns the email address directly
- **Multiple emails**: Returns semicolon-separated list for easy parsing

```ruby
# Single email
"user+1640995200001@example.com"

# Multiple emails  
"user+1640995200001@example.com;user+1640995200002@example.com;user+1640995200003@example.com"
```

## Requirements

- Ruby >= 2.7
- Optional: System clipboard utilities (xsel, wl-clipboard, or built-in on macOS/Windows)

## Development

After checking out the repo, run:

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rake spec

# Run linting
bundle exec rake rubocop

# Run all checks (linting + tests)
bundle exec rake
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`bundle exec rake`)
6. Commit your changes (`git commit -am 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

This project uses RuboCop for code style enforcement. Please ensure your code follows the established conventions by running:

```bash
bundle exec rake rubocop
```

## Versioning

This gem follows [Semantic Versioning](https://semver.org/). For available versions, see the [releases page](https://github.com/fabienpiette/mailaliaser/releases).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Support

- **Issues**: [GitHub Issues](https://github.com/fabienpiette/mailaliaser/issues)
- **Documentation**: This README and inline code documentation
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)

---

Made with ❤️ for the Ruby community