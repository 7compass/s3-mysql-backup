require 'aws/s3'

include AWS::S3


# wrapper for S3 operations
#
class S3Utils

  def initialize(access_key_id, secret_access_key, bucket)
    @bucket = bucket
    connect(access_key_id, secret_access_key)
    ensure_bucket_exists
    self
  end

  def copy(from, to)
    S3Object.copy(File.basename(from), File.basename(to), @bucket)
  end

  def store(file_path)
    S3Object.store(File.basename(file_path), open(file_path), @bucket)
  end

  def delete(file_path)
    S3Object.delete(File.basename(file_path), @bucket)
  end

  def list
    Bucket.find(@bucket).objects.each do |obj|
      puts "#{obj.bucket.name}/#{obj.key}"
    end
  end

  protected

  def connect(access_key_id, secret_access_key)
    AWS::S3::Base.establish_connection!(
      :access_key_id     => access_key_id,
      :secret_access_key => secret_access_key
    )
  end

  def ensure_bucket_exists
    Bucket.find(@bucket)

  rescue AWS::S3::NoSuchBucket
    Bucket.create(@bucket)
  end

end
