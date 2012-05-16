require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class ExtractJobGenerator < Thor::Group
      include Thor::Actions

      argument :source_release_path
      argument :source_item_name
      argument :job_name
      argument :flags, :type => :hash
      
      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end
      
      def using_source_release_for_templates
        source_paths << File.join(source_release_path)
      end

      def copy_job_dir
        if extract_job?
          directory "jobs/#{source_item_name}", "jobs/#{job_name}"
        end
      end
      
      def detect_files_to_extract
        @detector ||= Bosh::Gen::Models::ExtractDetection.new(source_release_path)
        if extract_job?
          @files = detector.extraction_files_for_job(source_item_name)
        else
          @files = detector.extraction_files_for_package(source_item_name)
        end
      end
      
      def copy_extracted_files
        # TODO
      end
      
      def detect_dependent_packages
        @packages = YAML.load_file(job_dir("spec"))["packages"]
      end
      
      def copy_dependent_packages
        @packages.each {|package| directory "packages/#{package}"}
      end

      def copy_dependent_sources
        @blobs = false
        @packages.each do |package|
          directory "src/#{package}" if File.exist?(File.join(source_release_path, "src", package))
          if File.exist?(File.join(source_release_path, "blobs", package))
            directory "blobs/#{package}"
            @blobs = true
          end
        end
      end
      
      def readme
        if @blobs
          say_status "readme", "Upload blobs with 'bosh upload blobs'"
        end
      end
      
      private
      def job_dir(path="")
        File.join("jobs", job_name, path)
      end
      
      def extract_job?
        !flags[:extract_package]
      end
      
      def extract_package?
        flags[:extract_package]
      end
    end
  end
end
