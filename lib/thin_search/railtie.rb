if defined?(Rails) then
  require "pathname"
  module ThinSearch
    class Railtie < ::Rails::Railtie
      def self.realpath(path)
        Pathname.new(path.to_s).realpath.to_s
      rescue Errno::ENOENT
        nil
      end

      # Internal: Return the capistrano root path
      #
      # Returns nil if we are not in a capistrano deploy
      # Returns the path of the capistrano root
      def self.cap_path
        return nil unless is_cap_deploy?

        rails_root  = realpath(Rails.root)
        shared_path = File.expand_path("../../shared", rails_root)
        cap_path    = File.dirname(shared_path)
        return cap_path
      end

      # Internal: Are we in a capistrano deploy.
      #
      # Basically checking to see there is a link between ../../shared/system
      # and public/system. If there is then we'll say we are in a capistrano
      # deploy
      #
      def self.is_cap_deploy?
        shared_public_system_path = File.expand_path('../../shared/system')
        public_path               = Rails.public_path.to_s
        public_system_path        = File.join(public_path, 'system')

        is_cap_deploy = File.exist?(shared_public_system_path) &&
                        File.link?(public_system_path) &&
                        (realpath(shared_public_system_path) == realpath(public_system_path))

        return is_cap_deploy
      end
    end
  end
end
