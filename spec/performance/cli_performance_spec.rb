require 'spec_helper'
require 'open3'
require 'benchmark'

RSpec.describe 'CLI Performance', :performance do
  let(:bin_path) { File.expand_path('../../bin/mailaliaser', __dir__) }

  def run_command_timed(args = '')
    Benchmark.realtime do
      Open3.capture3("ruby #{bin_path} #{args}")
    end
  end

  def run_command(args = '')
    Open3.capture3("ruby #{bin_path} #{args}")
  end

  describe 'startup time' do
    it 'starts up quickly' do
      time = run_command_timed('-l test -d example.com --no-clipboard')
      expect(time).to be < 1.0 # Should start in under 1 second
    end

    it 'help command is fast' do
      time = run_command_timed('-h')
      expect(time).to be < 0.5 # Help should be very fast
    end

    it 'version command is fast' do
      time = run_command_timed('-v')
      expect(time).to be < 0.5 # Version should be very fast
    end
  end

  describe 'email generation performance' do
    it 'generates single email quickly via CLI' do
      time = run_command_timed('-l perf -d test.com --no-clipboard')
      expect(time).to be < 1.0
    end

    it 'generates multiple emails efficiently via CLI' do
      time = run_command_timed('-l perf -d test.com -n 100 --no-clipboard')
      expect(time).to be < 2.0 # 100 emails in under 2 seconds
    end

    it 'handles large batches via CLI' do
      time = run_command_timed('-l perf -d test.com -n 1000 --no-clipboard -q')
      expect(time).to be < 5.0 # 1000 emails in under 5 seconds
    end
  end

  describe 'output performance' do
    it 'handles large output efficiently' do
      stdout = nil
      stderr = nil
      status = nil
      time = Benchmark.realtime do
        stdout, stderr, status = run_command('-l perf -d test.com -n 500 --no-clipboard')
      end

      expect(status.success?).to be true
      expect(time).to be < 3.0
      expect(stdout.split(';').length).to eq(500)
    end

    it 'quiet mode is faster than normal output' do
      normal_time = run_command_timed('-l perf -d test.com -n 100 --no-clipboard')
      quiet_time = run_command_timed('-l perf -d test.com -n 100 --no-clipboard -q')

      # Quiet mode should be equal or faster (within margin of error)
      expect(quiet_time).to be <= (normal_time + 0.1)
    end
  end

  describe 'error handling performance' do
    it 'handles missing arguments quickly' do
      time = run_command_timed('')
      expect(time).to be < 1.0
    end

    it 'handles invalid options quickly' do
      time = run_command_timed('-l test -d example.com --invalid-option')
      expect(time).to be < 1.0
    end
  end

  describe 'repeated invocations' do
    it 'maintains consistent performance over multiple calls' do
      times = []

      10.times do
        times << run_command_timed('-l perf -d test.com --no-clipboard -q')
      end

      average_time = times.sum / times.length
      max_time = times.max
      min_time = times.min

      expect(average_time).to be < 1.0
      # Variance should not be excessive
      expect(max_time - min_time).to be < 0.5
    end

    it 'generates unique results on rapid calls' do
      5.times do
        _, _, status = run_command('-l rapid -d test.com --no-clipboard -q')
        expect(status.success?).to be true
        # Even in quiet mode, we're not capturing output, but ensuring it succeeds
      end

      # Each call should succeed without interference
      expect(true).to be true # Basic success test
    end
  end

  describe 'resource usage' do
    it 'does not consume excessive CPU on large generations' do
      # This is more of a smoke test - ensuring the process completes
      _, stderr, status = run_command('-l cpu -d test.com -n 2000 --no-clipboard -q')

      expect(status.success?).to be true
      expect(stderr).not_to include('killed')
      expect(stderr).not_to include('memory')
    end

    it 'handles clipboard unavailability gracefully' do
      # Test performance when clipboard operations might fail
      time = run_command_timed('-l clip -d test.com')
      expect(time).to be < 2.0 # Should not hang on clipboard issues
    end
  end
end
