include_recipe 'smf'

execute 'verify nagios' do
  action :nothing
  command 'nagios -v /opt/local/etc/nagios/nagios.cfg'
  environment 'PATH' => node['paths']['bin_path']
  notifies :restart, 'service[nagios]'
end

template '/opt/local/sbin/nagios-dependencies' do
  mode 0755
end

smf 'pkgsrc/nagios' do
  action :delete
end

smf 'nagios-dependencies' do
  fmri '/application/setup/nagios-dependencies'
  start_command '/opt/local/sbin/nagios-dependencies'
  stop_command 'true'
  duration 'transient'
  manifest_type 'setup'
  dependencies [
      {'name' => 'multi-user', 'fmris' => ['svc:/milestone/multi-user'],
        'grouping' => 'require_all', 'restart_on' => 'none', 'type' => 'service'}
    ]
  notifies :run, 'execute[verify nagios]'
  notifies :enable, 'service[nagios-dependencies]', :immediately
end

smf 'nagios' do
  fmri '/application/nagios'
  user 'nagios'
  group 'nagios'
  start_command '/opt/local/bin/nagios -d %{config_file}'
  start_timeout 60
  stop_timeout 60
  ignore %w(core signal)
  working_directory '/var/spool/nagios'
  property_groups({
      'application' => {
        'config_file' => '/opt/local/etc/nagios/nagios.cfg'
      }
    })

  dependencies [
      {'name' => 'nagios-dependencies', 'fmris' => ['svc:/application/setup/nagios-dependencies'],
        'grouping' => 'require_all', 'restart_on' => 'none', 'type' => 'service'}
    ]
  notifies :run, 'execute[verify nagios]'
end

service 'nagios'
service 'nagios-dependencies'
