require 'aws-sdk'

# wrapper for S3 operations
#
class S3Utils

  def initialize(access_key_id, secret_access_key, bucket_name, server=nil)
    @bucket_name   = bucket_name
    @s3_connection = connect(access_key_id, secret_access_key, server)
    @s3_bucket     = get_or_create_bucket
    self
  end

  def store(file_path)
    @s3_bucket.objects.create(File.basename(file_path), open(file_path))
  end

  def delete(file_path)
    @s3_bucket.objects[File.basename(file_path)].delete
  end

  def list
    @s3_bucket.objects.each do |obj|
      puts "#{obj.bucket.name}/#{obj.key}"
    end
  end

  protected

  def connect(access_key_id, secret_access_key, server=nil)
    if server == nil
      AWS::S3::new(
        :access_key_id     => access_key_id,
        :secret_access_key => secret_access_key
      )
    else
      AWS::S3::new(
        :access_key_id     => access_key_id,
        :secret_access_key => secret_access_key,
        :server            => server
      )
    end
  end

  def get_or_create_bucket
    if @s3_connection.buckets[@bucket_name].exists?
      @s3_connection.buckets[@bucket_name]
    else
      @s3_connection.buckets.create(@bucket_name)
    end
  end

end
