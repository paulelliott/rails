require "isolation/abstract_unit"

module ApplicationTests
  module RakeTests
    class RakeNotesTest < ActiveSupport::TestCase
      def setup
        build_app
        require "rails/all"
      end

      def teardown
        teardown_app
      end

      test 'notes' do
        app_file "app/views/home/index.html.erb", "<% # TODO: note in erb %>"
        app_file "app/views/home/index.html.haml", "-# TODO: note in haml"
        app_file "app/views/home/index.html.slim", "/ TODO: note in slim"
        app_file "app/assets/javascripts/application.js.coffee", "# TODO: note in coffee"
        app_file "app/assets/javascripts/application.js", "// TODO: note in js"
        app_file "app/assets/stylesheets/application.css", "// TODO: note in css"
        app_file "app/assets/stylesheets/application.css.scss", "// TODO: note in scss"
        app_file "app/controllers/application_controller.rb", 1000.times.map { "" }.join("\n") << "# TODO: note in ruby"

        boot_rails
        require 'rake'
        require 'rdoc/task'
        require 'rake/testtask'

        Rails.application.load_tasks

        Dir.chdir(app_path) do
          output = `bundle exec rake notes`
          lines = output.scan(/\[([0-9\s]+)\](\s)/)

          assert_match /note in erb/, output
          assert_match /note in haml/, output
          assert_match /note in slim/, output
          assert_match /note in ruby/, output
          assert_match /note in coffee/, output
          assert_match /note in js/, output
          assert_match /note in css/, output
          assert_match /note in scss/, output

          assert_equal 8, lines.size

          lines.each do |line|
            assert_equal 4, line[0].size
            assert_equal ' ', line[1]
          end
        end

      end

      private
      def boot_rails
        super
        require "#{app_path}/config/environment"
      end
    end
  end
end
