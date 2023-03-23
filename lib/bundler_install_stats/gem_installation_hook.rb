# frozen_string_literal: true

require "bundler/plugin/events"

module BundlerInstallStats
  class GemInstallationHook
    class << self
      def register
        @private_gem_times = {}
        @public_gem_times = {}
        @mutex = Mutex.new

        #   A hook called before each individual gem is installed
        #   Includes a Bundler::ParallelInstaller::SpecInstallation.
        #   No state, error, post_install_message will be present as nothing has installed yet
        #   GEM_BEFORE_INSTALL = "before-install"
        Bundler::Plugin.add_hook(Bundler::Plugin::Events::GEM_BEFORE_INSTALL) do |gem_spec|
          now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          public_gem = public_gem?(gem_spec.spec)

          unless public_gem
            puts "\n\n"
            puts "*" * 20
            pp(gem_spec.spec.source.remotes.collect(&:host))
            puts "*" * 20
            puts "\n\n"
          end

          @mutex.synchronize do
            if public_gem
              @public_gem_times[gem_spec.full_name] = now
            else
              @private_gem_times[gem_spec.full_name] = now
            end
          end
        end

        #   A hook called after each individual gem is installed
        #   Includes a Bundler::ParallelInstaller::SpecInstallation.
        #     - If state is failed, an error will be present.
        #     - If state is success, a post_install_message may be present.
        #   GEM_AFTER_INSTALL = "after-install"
        Bundler::Plugin.add_hook(Bundler::Plugin::Events::GEM_AFTER_INSTALL) do |gem_spec|
          now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          public_gem = public_gem?(gem_spec.spec)

          diff = @mutex.synchronize do
            if public_gem
              @public_gem_times[gem_spec.full_name] = now - @public_gem_times[gem_spec.full_name]
            else
              @private_gem_times[gem_spec.full_name] = now - @private_gem_times[gem_spec.full_name]
            end
          end

          puts "#{gem_spec.full_name} took #{diff}s to install"
        end

        #   A hook called before any gems install
        #   Includes an Array of Bundler::Dependency objects
        #   GEM_BEFORE_INSTALL_ALL = "before-install-all"
        Bundler::Plugin.add_hook(Bundler::Plugin::Events::GEM_BEFORE_INSTALL_ALL) do |_dependencies|
          puts "Before all gem installation"
        end

        #   A hook called after any gems install
        #   Includes an Array of Bundler::Dependency objects
        #   GEM_AFTER_INSTALL_ALL = "after-install-all"
        Bundler::Plugin.add_hook(Bundler::Plugin::Events::GEM_AFTER_INSTALL_ALL) do |_dependencies|
          puts "After all gem installation (times in seconds)"

          @mutex.synchronize do
            puts "Private gems:"
            pp(@private_gem_times.sort_by { |_k, v| v }.to_h)

            puts "\n\nPublic gems:"
            pp(@public_gem_times.sort_by { |_k, v| v }.to_h)
          end
        end
      end

      def public_gem?(gem_spec)
        remotes = begin
          gem_spec.source.remotes
        rescue
          []
        end
        remotes.all? do |r|
          r.host == "rubygems.org"
        rescue
          false
        end
      end
    end
  end
end
