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
      attr_reader :server_aliases

      def initialize(name, run_context = nil)
        super
        @resource_name = :nagios
        @provider = Chef::Provider::Nagios
        @action = :install
        @allowed_actions = [:install, :nothing, :restart, :verify]

        @server_aliases = []
      end

      def name(arg = nil)
        set_or_return(:name, arg, kind_of: String)
      end

      def server_name(arg = nil)
        set_or_return(:server_name, arg, kind_of: String, required: true)
      end

      def url_html_path(arg = nil)
        set_or_return(:url_html_path, arg, kind_of: String, default: '/nagios')
      end

      def server_alias(alias_name)
        @server_aliases << alias_name
      end
    end
  end
end
