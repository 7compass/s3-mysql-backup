require "spec_helper"

describe S3MysqlBackup do

  context "with smtp stubbed" do
    before :each do
      @config = YAML::load_file(File.dirname(__FILE__) + '/s3_mysql_backup.yml')
      stub.instance_of(S3MysqlBackup).config.times(any_times){ @config }

      stub.instance_of(S3MysqlBackup).ensure_backup_dir_exists.times(any_times){ true }

      @dump_file_name = "/tmp/test.20130101.010101.sql.gz"
      stub.instance_of(S3MysqlBackup).dump_db.times(any_times){ @dump_file_name }

      mock_stats = Object.new
      stub(File).stat.with_any_args.times(any_times){ mock_stats }
      stub(mock_stats).size{ 1024 }

      mock_utils = Object.new
      stub(S3Utils).new.with_any_args.times(any_times){ mock_utils }
      stub.instance_of(S3MysqlBackup).connect_to_s3.times(any_times){ mock_utils }

      stub.instance_of(Net::SMTP).enable_starttls.times(any_times)
      stub.instance_of(Net::SMTP).start.with_any_args.times(any_times){ true }
    end

    describe "#run" do
      it "should call ensure_backup_dir_exists" do
        stub.instance_of(S3MysqlBackup).ensure_backup_dir_exists.times(1)
        S3MysqlBackup.new('test', @config_path).run
      end

      it "should call connect_to_s3" do
        stub.instance_of(S3MysqlBackup).connect_to_s3.times(1)
        S3MysqlBackup.new('test', @config_path).run
      end

      it "should call remove_old_backups" do
        stub.instance_of(S3MysqlBackup).remove_old_backups.times(1)
        S3MysqlBackup.new('test', @config_path).run
      end

      it "should call dump_db" do
        stub.instance_of(S3MysqlBackup).dump_db.times(1){ @dump_file_name }
        S3MysqlBackup.new('test', @config_path).run
      end

      it "should call mail_notification" do
        stub.instance_of(S3MysqlBackup).mail_notification.times(1)
        S3MysqlBackup.new('test', @config_path).run
      end
    end
  end

  context "without smtp stubbed" do
    before :each do
      # @config = YAML::load_file(File.dirname(__FILE__) + '/s3_mysql_backup.yml')
      # stub.instance_of(S3MysqlBackup).config.times(any_times){ @config }

      stub.instance_of(S3MysqlBackup).ensure_backup_dir_exists.times(any_times){ true }

      @dump_file_name = "/tmp/test.20130101.010101.sql.gz"
      stub.instance_of(S3MysqlBackup).dump_db.times(any_times){ @dump_file_name }

      mock_stats = Object.new
      stub(File).stat.with_any_args.times(any_times){ mock_stats }
      stub(mock_stats).size{ 1024 }

      mock_utils = Object.new
      stub(S3Utils).new.with_any_args.times(any_times){ mock_utils }
      stub.instance_of(S3MysqlBackup).connect_to_s3.times(any_times){ mock_utils }

      stub.instance_of(Net::SMTP).send_message.with_any_args.times(any_times)
    end

    describe "#mail_notification" do
      it "should not raise with integer password" do
        expect{

          begin
            S3MysqlBackup.new('test', {
                                        backup_dir: "/tmp/s3_mysql_backups",
                                        s3_access_key_id: "my-key",
                                        s3_secret_access_key: "my-secret",
                                        s3_bucket: "my-bucket",
                                        dump_user: "my-user",
                                        dump_pass: "my-pass",
                                        mail_to: "recipient@example.com",
                                        mail_user: "me@gmail.com",
                                        mail_pass: 12345,
                                        mail_start_tls: true,
                                      }
              ).send :mail_notification, "some_file_name"

          rescue Exception => e
            raise e if e.is_a?(TypeError)
          end

          }.not_to raise_error
      end
    end

  end

end