module Mailaliaser
  class Generator
    def initialize(local_part:, domain:, number: 1, clipboard: true, quiet: false)
      @local_part = local_part
      @domain = domain
      @number = number
      @clipboard = clipboard
      @quiet = quiet
    end

    def generate
      base_timestamp = (Time.now.to_f * 1000).to_i # Millisecond precision

      emails = (1..@number).map do |i|
        "#{@local_part}+#{base_timestamp}#{i}@#{@domain}"
      end

      result = format_result(emails)

      puts result unless @quiet

      copy_to_clipboard(result) if @clipboard

      result
    end

    private

    def format_result(emails)
      return emails.first if emails.size == 1

      emails.join(';')
    end

    def copy_to_clipboard(text)
      require 'clipboard'
      Clipboard.copy(text)
    rescue LoadError
      warn 'clipboard gem not available - install with: gem install clipboard'
    rescue StandardError => e
      warn "clipboard functionality not available: #{e.message}"
    end
  end
end
