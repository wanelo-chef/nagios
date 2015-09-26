require 'chef/mixin/shell_out'

class Chef
  class Provider
    # Provider for the nagios Chef provider
    #
    # nagios 'nagios' do
    #   service_name 'nagios.example.com'
    # end
    #
    class Nagios < Chef::Provider::LWRPBase
      include Chef::Mixin::ShellOut

      def load_current_resource
        @current_resource ||= new_resource.class.new(new_resource.name)
      end

      def action_install
        new_resource.updated_by_last_action(false)

        install_packages
        configure_nagios
        install_service
        configure_nginx
      end

      def action_restart
        Chef::Log.warn "Nagios: Restarting service"
        new_resource.notifies_immediately(:restart, nagios_service)
        new_resource.updated_by_last_action(true)
      end

      def action_verify
        Chef::Log.warn "Nagios: Verifying configuration"

        execute 'verify nagios configuration' do
          command '/opt/local/bin/nagios -v /opt/local/etc/nagios/nagios.cfg'
          environment 'PATH' => node['paths']['bin_path']
          notifies :restart, new_resource.to_s, :immediately
        end
        new_resource.updated_by_last_action(true)
      end

      private

      def configure_nagios
        template '/opt/local/etc/nagios/cgi.cfg' do
          source 'nagios/cgi.cfg.erb'
          cookbook 'nagios'
          owner 'nagios'
          group 'nagios'
          mode 0644
          notifies :verify, new_resource.to_s
        end
      end

      def configure_nginx
        run_context.include_recipe 'nginx'

        template '/opt/local/etc/nginx/sites-available/nagios.conf' do
          source 'nginx/nagios.conf.erb'
          cookbook 'nagios'
          owner 'www'
          group 'www'
          mode 0644
          variables 'server_name' => new_resource.server_name
          notifies :run, 'execute[verify nginx configuration file]'
        end

        nginx_site 'nagios.conf' do
          enable true
        end

        execute 'verify nginx configuration file' do
          command 'nginx -t -c /opt/local/etc/nginx/nginx.conf'
          action :nothing
          notifies :reload, 'service[nginx]'
        end
      end

      def install_packages
        %w(php55-fpm spawn-fcgi fcgiwrap nagios-base).each do |pkg|
          package pkg
        end
      end

      def install_service
        run_context.include_recipe 'smf'

        smf 'pkgsrc/nagios' do
          action :delete
        end

        template '/opt/local/sbin/nagios-dependencies' do
          source 'nagios-dependencies.erb'
          cookbook 'nagios'
          mode 0755
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
          notifies :enable, 'service[nagios-dependencies]', :immediately
          notifies :verify, new_resource.to_s
        end

        service 'nagios-dependencies'

        smf 'nagios' do
          fmri '/application/nagios'
          user 'nagios'
          group 'nagios'
          start_command '/opt/local/bin/nagios -d %{config_file}'
          start_timeout 70
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
          notifies :verify, new_resource.to_s
        end
      end

      def nagios_service
        begin
          run_context.resource_collection.find(:service => 'nagios')
        rescue Chef::Exceptions::ResourceNotFound
          service 'nagios' do
            supports restart: true, status: true, reload: true
          end
        end
      end
    end
  end
end
