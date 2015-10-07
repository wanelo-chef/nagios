require 'spec_helper'

RSpec.describe 'nagios::install' do
  describe service('nagios-dependencies') do
    it { should be_running }
  end

  describe service('nagios') do
    it { should be_running }
  end

  describe service('nginx') do
    it { should be_running }
  end

  describe service('php-fpm') do
    it { should be_running }
  end
end
