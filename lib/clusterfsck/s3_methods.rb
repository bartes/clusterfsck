module ClusterFsck
  module S3Methods

    class ConflictError < StandardError; end
    class KeyDoesNotExistError < StandardError; end

    def s3_object(object_name)
      bucket.objects[full_s3_path(object_name)]
    end

    def bucket
      @bucket ||= s3.buckets[ClusterFsck.config_bucket]
    end

    def credentials
      S3Methods.credentials
    end

    def self.credentials
      @credentials ||= CredentialGrabber.find
    end

    def s3
      S3Methods.s3
    end

    def self.s3
      if credentials
        AWS::S3.new(credentials) #could be nil, especially if on EC2
      else
        AWS::S3.new
      end
    end

    def all_files
      bucket.objects.with_prefix(cluster_fsck_env).collect(&:key)
    end

    def all_environments
      bucket.objects.map(&:key).map {|key| key.split('/').first }.uniq
    end

    def full_s3_path(key)
      "#{cluster_fsck_env}/#{key}"
    end

    def cluster_fsck_env
      @cluster_fsck_env || ClusterFsck.cluster_fsck_env
    end

  end
end
