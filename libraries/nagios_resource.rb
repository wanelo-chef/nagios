class Chef
  class Resource
    # Resource for the nagios Chef provider
    #
    # nagios 'nagios' do
    #   server_name 'nagios.example.com'
    #   action :install
    # end
    #
    class Nagios < Chef::Resource
      def initialize(name, run_context = nil)
        super
        @resource_name = :nagios
        @provider = Chef::Provider::Nagios
        @action = :install
        @allowed_actions = [:install, :nothing, :restart, :verify]
      end

      def name(arg = nil)
        set_or_return(:name, arg, kind_of: String)
      end

      def server_name(arg = nil)
        set_or_return(:server_name, arg, kind_of: String, required: true)
      end
    end
  end
end
