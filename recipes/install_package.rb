package 'nagios-base' do
  notifies :run, 'execute[verify nagios]'
end

include_recipe 'nagios::service'
