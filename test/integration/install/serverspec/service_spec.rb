require 'spec_helper'

RSpec.describe 'nagios::install' do
  describe service('nagios') do
    it { should be_running }
  end
end
