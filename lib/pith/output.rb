require "fileutils"
require "pith/render_context"

module Pith

  class Output

    def self.for(input)
      new(input)
    end

    def initialize(input)
      @input = input
    end

    attr_reader :input
    attr_reader :dependencies
    attr_reader :error

    def project
      input.project
    end

    def path
      input.output_path
    end

    def file
      @file ||= project.output_dir + path
    end

    # Return true if output needs to be re-generated.
    #
    def uptodate?
      dependencies && FileUtils.uptodate?(file, dependencies)
    end

    # Generate output for this template
    #
    def generate
      logger.info("--> #{path}")
      file.parent.mkpath
      if input.resource?
        copy_resource
      else
        evaluate_template
      end
    end

    private

    def copy_resource
      FileUtils.copy(input.file, file)
      @dependencies = [input.file]
    end

    def evaluate_template
      render_context = RenderContext.new(project)
      file.open("w") do |out|
        begin
          @error = nil
          out.puts(render_context.render(input))
        rescue StandardError, SyntaxError => e
          @error = e
          logger.warn exception_summary(e, :max_backtrace => 5)
          out.puts "<pre>"
          out.puts exception_summary(e)
        end
      end
      @dependencies = render_context.dependencies
    end

    def logger
      project.logger
    end

    def exception_summary(e, options = {})
      max_backtrace = options[:max_backtrace] || 999
      trimmed_backtrace = e.backtrace[0, max_backtrace]
      (["#{e.class}: #{e.message}"] + trimmed_backtrace).join("\n    ") + "\n"
    end

  end

end