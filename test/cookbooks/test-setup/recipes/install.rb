include_recipe 'nagios::default'

nagios 'nagios' do
  server_name 'nagios.example.com'
  action :install
end

execute 'proxy server name in hosts file' do
  command 'echo "127.0.0.1 nagios.example.com" >> /etc/hosts'
  not_if 'grep nagios.example.com /etc/hosts'
end
