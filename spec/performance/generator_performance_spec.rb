require 'spec_helper'
require 'benchmark'

RSpec.describe 'Mailaliaser::Generator Performance', :performance do
  let(:generator) { Mailaliaser::Generator.new(local_part: 'perf', domain: 'test.com', clipboard: false, quiet: true) }

  describe 'single email generation' do
    it 'generates single email in reasonable time' do
      time = Benchmark.realtime do
        generator.generate
      end

      expect(time).to be < 0.01 # Should be under 10ms
    end

    it 'generates email consistently' do
      times = []
      10.times do
        times << Benchmark.realtime { generator.generate }
      end

      average_time = times.sum / times.length
      expect(average_time).to be < 0.005 # Average under 5ms
    end
  end

  describe 'multiple email generation' do
    it 'generates 100 emails efficiently' do
      multi_generator = Mailaliaser::Generator.new(
        local_part: 'perf',
        domain: 'test.com',
        number: 100,
        clipboard: false,
        quiet: true
      )

      time = Benchmark.realtime do
        multi_generator.generate
      end

      expect(time).to be < 0.1 # Should be under 100ms for 100 emails
    end

    it 'generates 1000 emails in reasonable time' do
      large_generator = Mailaliaser::Generator.new(
        local_part: 'perf',
        domain: 'test.com',
        number: 1000,
        clipboard: false,
        quiet: true
      )

      time = Benchmark.realtime do
        large_generator.generate
      end

      expect(time).to be < 1.0 # Should be under 1 second for 1000 emails
    end

    it 'scales linearly with number of emails' do
      small_count = 10
      large_count = 100

      small_generator = Mailaliaser::Generator.new(
        local_part: 'perf',
        domain: 'test.com',
        number: small_count,
        clipboard: false,
        quiet: true
      )

      large_generator = Mailaliaser::Generator.new(
        local_part: 'perf',
        domain: 'test.com',
        number: large_count,
        clipboard: false,
        quiet: true
      )

      small_time = Benchmark.realtime { small_generator.generate }
      large_time = Benchmark.realtime { large_generator.generate }

      # Large should be roughly 10x slower (with some tolerance for overhead)
      ratio = large_time / small_time
      expect(ratio).to be_between(5, 20) # Allow for some variance
    end
  end

  describe 'memory usage' do
    it 'does not leak memory with repeated generation' do
      # Ruby doesn't have built-in memory profiling, but we can test for basic efficiency
      initial_objects = ObjectSpace.count_objects[:T_STRING]

      1000.times do
        generator.generate
      end

      final_objects = ObjectSpace.count_objects[:T_STRING]
      created_objects = final_objects - initial_objects

      # Should not create excessive string objects (allowing for some variance)
      expect(created_objects).to be < 5000
    end

    it 'generates emails without accumulating large arrays' do
      large_generator = Mailaliaser::Generator.new(
        local_part: 'perf',
        domain: 'test.com',
        number: 1000,
        clipboard: false,
        quiet: true
      )

      result = large_generator.generate

      # Result should be a single string, not an array
      expect(result).to be_a(String)
      # Should contain semicolons for multiple emails
      expect(result.split(';').length).to eq(1000)
    end
  end

  describe 'concurrent access' do
    it 'handles concurrent generation safely' do
      threads = []
      results = []
      mutex = Mutex.new

      10.times do
        threads << Thread.new do
          local_generator = Mailaliaser::Generator.new(
            local_part: 'thread',
            domain: 'test.com',
            clipboard: false,
            quiet: true
          )
          result = local_generator.generate
          mutex.synchronize { results << result }
        end
      end

      threads.each(&:join)

      # Allow for some collisions in concurrent access
      expect(results.uniq.length).to be >= 3 # Some uniqueness in concurrent threads
      # All should be valid email format
      results.each do |email|
        expect(email).to match(/thread\+\d+1@test\.com/)
      end
    end
  end

  describe 'stress testing' do
    it 'handles rapid sequential calls' do
      start_time = Time.now

      100.times do
        generator.generate
      end

      total_time = Time.now - start_time
      expect(total_time).to be < 1.0 # 100 calls in under 1 second
    end

    it 'generates emails rapidly without errors' do
      emails = []

      time = Benchmark.realtime do
        50.times do
          # Create a new generator instance each time
          test_generator = Mailaliaser::Generator.new(
            local_part: 'rapid',
            domain: 'test.com',
            clipboard: false,
            quiet: true
          )
          emails << test_generator.generate
        end
      end

      # Performance check - should complete quickly
      expect(time).to be < 0.5 # 50 generators in under 500ms
      expect(emails.length).to eq(50)
      # All should be valid email format
      emails.each do |email|
        expect(email).to match(/rapid\+\d+1@test\.com/)
      end
    end
  end
end
