require 'commander'

module ClusterFsck
  module Commands
    class Edit
      include Commander::UI
      include AmicusEnvArgumentParser

      def run_command(args, options = Hashie::Mash.new)
        set_amicus_env_and_key_from_args(args)

        @options = options
        raise ArgumentError, "File #{key} is overridden locally! use --force to force" if reader.has_local_override? and !options.force

        new_yaml = ask_editor(YAML.dump(reader.read(remote_only: true).to_hash))
        writer.set(Configuration.from_yaml(new_yaml), reader.version_count)
      end

      def writer
        @writer ||= ClusterFsck::Writer.new(key, amicus_env: reader.amicus_env)
      end

      def reader
        @reader ||= ClusterFsck::Reader.new(key, amicus_env: amicus_env)
      end

    end
  end
end
