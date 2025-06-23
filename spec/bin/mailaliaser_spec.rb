require 'spec_helper'
require 'open3'

RSpec.describe 'mailaliaser CLI' do
  let(:bin_path) { File.expand_path('../../bin/mailaliaser', __dir__) }

  def run_command(args = '')
    Open3.capture3("ruby #{bin_path} #{args}")
  end

  describe 'required parameters' do
    it 'requires local-part and domain' do
      _, stderr, status = run_command

      expect(status.success?).to be false
      expect(stderr).to include('missing required option')
    end
  end

  describe 'basic functionality' do
    it 'generates an email with provided settings' do
      stdout, _, status = run_command('-l test -d example.com')

      expect(status.success?).to be true
      expect(stdout).to match(/test\+\d+1@example\.com/)
    end
  end

  describe 'custom local part' do
    it 'uses custom local part' do
      stdout, _, status = run_command('-l john -d example.com')

      expect(status.success?).to be true
      expect(stdout).to match(/john\+\d+1@example\.com/)
    end
  end

  describe 'custom domain' do
    it 'uses custom domain' do
      stdout, _, status = run_command('-l test -d custom.org')

      expect(status.success?).to be true
      expect(stdout).to match(/test\+\d+1@custom\.org/)
    end
  end

  describe 'multiple emails' do
    it 'generates multiple emails' do
      stdout, _, status = run_command('-l test -d example.com -n 3')

      expect(status.success?).to be true
      expect(stdout.strip.split(';').length).to eq(3)
      expect(stdout).to match(/test\+\d+1@example\.com;test\+\d+2@example\.com;test\+\d+3@example\.com/)
    end
  end

  describe 'quiet mode' do
    it 'suppresses output' do
      stdout, _, status = run_command('-l test -d example.com -q')

      expect(status.success?).to be true
      expect(stdout).to be_empty
    end
  end

  describe 'combined options' do
    it 'works with multiple options' do
      stdout, _, status = run_command('-l jane -d test.org -n 2')

      expect(status.success?).to be true
      expect(stdout.strip.split(';').length).to eq(2)
      expect(stdout).to match(/jane\+\d+1@test\.org;jane\+\d+2@test\.org/)
    end
  end

  describe 'help option' do
    it 'displays help message' do
      stdout, _, status = run_command('-h')

      expect(status.success?).to be true
      expect(stdout).to include('Usage: mailaliaser [options]')
      expect(stdout).to include('Generates a unique random email')
      expect(stdout).to include('--local-part')
      expect(stdout).to include('--domain')
      expect(stdout).to include('--number')
      expect(stdout).to include('--clipboard')
      expect(stdout).to include('--quiet')
    end
  end

  describe 'version option' do
    it 'displays version information' do
      stdout, _, status = run_command('-v')

      expect(status.success?).to be true
      expect(stdout).to include("Mailaliaser version: #{Mailaliaser::VERSION}")
      expect(stdout).to include('Slop version:')
      expect(stdout).to match(/Clipboard (version:|: not installed)/)
    end
  end

  describe 'long options' do
    it 'works with long option names' do
      stdout, _, status = run_command('--local-part alice --domain example.org --number 2 --quiet')

      expect(status.success?).to be true
      expect(stdout).to be_empty
    end
  end

  describe 'clipboard option' do
    it 'accepts clipboard flag' do
      stdout, _, status = run_command('-l test -d example.com --no-clipboard')

      expect(status.success?).to be true
      expect(stdout).to match(/test\+\d+1@example\.com/)
    end
  end

  describe 'invalid options' do
    it 'handles invalid options gracefully' do
      _, stderr, status = run_command('-l test -d example.com --invalid-option')

      expect(status.success?).to be false
      expect(stderr).to include('unknown option')
    end
  end
end
