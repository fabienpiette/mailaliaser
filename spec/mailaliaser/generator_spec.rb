require 'spec_helper'

RSpec.describe Mailaliaser::Generator do
  let(:generator) { described_class.new(local_part: 'test', domain: 'example.com') }

  describe '#initialize' do
    it 'requires local_part and domain parameters' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'sets provided values' do
      expect(generator.instance_variable_get(:@local_part)).to eq('test')
      expect(generator.instance_variable_get(:@domain)).to eq('example.com')
      expect(generator.instance_variable_get(:@number)).to eq(1)
      expect(generator.instance_variable_get(:@clipboard)).to be true
      expect(generator.instance_variable_get(:@quiet)).to be false
    end

    it 'accepts custom values' do
      custom_generator = described_class.new(
        local_part: 'john',
        domain: 'example.com',
        number: 3,
        clipboard: false,
        quiet: true
      )

      expect(custom_generator.instance_variable_get(:@local_part)).to eq('john')
      expect(custom_generator.instance_variable_get(:@domain)).to eq('example.com')
      expect(custom_generator.instance_variable_get(:@number)).to eq(3)
      expect(custom_generator.instance_variable_get(:@clipboard)).to be false
      expect(custom_generator.instance_variable_get(:@quiet)).to be true
    end
  end

  describe '#generate' do
    let(:time_now) { 1_640_995_200.123 } # Fixed timestamp for testing
    let(:timestamp_ms) { (time_now * 1000).to_i } # Convert to milliseconds

    before do
      allow(Time).to receive(:now).and_return(double(to_f: time_now))
    end

    context 'when generating single email' do
      it 'generates correct email format' do
        allow($stdout).to receive(:puts)

        result = generator.generate

        expect(result).to eq("test+#{timestamp_ms}1@example.com")
      end

      it 'outputs to stdout by default' do
        expect { generator.generate }.to output("test+#{timestamp_ms}1@example.com\n").to_stdout
      end

      it 'attempts to copy to clipboard by default' do
        allow($stdout).to receive(:puts)
        allow(generator).to receive(:copy_to_clipboard)

        generator.generate

        expect(generator).to have_received(:copy_to_clipboard).with("test+#{timestamp_ms}1@example.com")
      end
    end

    context 'when generating multiple emails' do
      let(:multi_generator) { described_class.new(local_part: 'test', domain: 'example.com', number: 3) }

      it 'generates correct number of emails' do
        allow($stdout).to receive(:puts)

        result = multi_generator.generate

        expected = [
          "test+#{timestamp_ms}1@example.com",
          "test+#{timestamp_ms}2@example.com",
          "test+#{timestamp_ms}3@example.com"
        ].join(';')

        expect(result).to eq(expected)
      end

      it 'joins multiple emails with semicolon' do
        allow($stdout).to receive(:puts)

        result = multi_generator.generate

        expect(result).to include(';')
        expect(result.split(';').length).to eq(3)
      end
    end

    context 'when quiet mode is enabled' do
      let(:quiet_generator) { described_class.new(local_part: 'test', domain: 'example.com', quiet: true) }

      it 'does not output to stdout' do
        expect { quiet_generator.generate }.not_to output.to_stdout
      end

      it 'still attempts to copy to clipboard' do
        allow(quiet_generator).to receive(:copy_to_clipboard)

        quiet_generator.generate

        expect(quiet_generator).to have_received(:copy_to_clipboard)
      end
    end

    context 'when clipboard is disabled' do
      let(:no_clipboard_generator) { described_class.new(local_part: 'test', domain: 'example.com', clipboard: false) }

      it 'does not copy to clipboard' do
        allow($stdout).to receive(:puts)
        allow(no_clipboard_generator).to receive(:copy_to_clipboard)

        no_clipboard_generator.generate

        expect(no_clipboard_generator).not_to have_received(:copy_to_clipboard)
      end
    end

    context 'with custom local part and domain' do
      let(:custom_generator) do
        described_class.new(
          local_part: 'jane',
          domain: 'test.org',
          quiet: true
        )
      end

      it 'uses custom values in email generation' do
        result = custom_generator.generate

        expect(result).to eq("jane+#{timestamp_ms}1@test.org")
      end
    end
  end

  describe 'timestamp uniqueness' do
    it 'generates different timestamps for sequential calls' do
      allow($stdout).to receive(:puts)
      allow(generator).to receive(:copy_to_clipboard)

      first_time = 1_640_995_200.123
      second_time = 1_640_995_201.456
      first_timestamp_ms = (first_time * 1000).to_i
      second_timestamp_ms = (second_time * 1000).to_i

      allow(Time).to receive(:now).and_return(
        double(to_f: first_time),
        double(to_f: second_time)
      )

      first_result = generator.generate
      second_result = generator.generate

      expect(first_result).to eq("test+#{first_timestamp_ms}1@example.com")
      expect(second_result).to eq("test+#{second_timestamp_ms}1@example.com")
      expect(first_result).not_to eq(second_result)
    end
  end

  describe '#copy_to_clipboard' do
    it 'handles clipboard errors gracefully' do
      allow(generator).to receive(:require).with('clipboard').and_raise(LoadError)
      expect { generator.send(:copy_to_clipboard, 'test') }.not_to raise_error
    end

    it 'handles clipboard runtime errors gracefully' do
      allow(generator).to receive(:require).with('clipboard')
      stub_const('Clipboard', double)
      allow(Clipboard).to receive(:copy).and_raise(StandardError, 'clipboard error')
      expect { generator.send(:copy_to_clipboard, 'test') }.not_to raise_error
    end
  end
end
