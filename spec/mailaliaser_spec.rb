require 'spec_helper'

RSpec.describe Mailaliaser do
  it 'has a version number' do
    expect(Mailaliaser::VERSION).not_to be_nil
    expect(Mailaliaser::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it 'loads the Generator class' do
    expect(defined?(Mailaliaser::Generator)).to eq('constant')
  end
end
