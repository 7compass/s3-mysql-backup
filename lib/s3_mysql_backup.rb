require "net/smtp"
require "time"
require 'fileutils'
require 'yaml'

require File.dirname(__FILE__) + '/s3utils'

#
class S3MysqlBackup

  def initialize(db_name, path_to_config)
    @db_name        = db_name
    @path_to_config = path_to_config

    self
  end

  def run
    ensure_backup_dir_exists
    connect_to_s3
    remove_old_backups
    mail_notification(dump_db)
  end


  protected

  def config
    defaults = {
      "dump_host"           => "localhost",
      "mail_domain"         => "smtp.gmail.com",
      "mail_port"           => "587",
      "mail_authentication" => :login,
      "backup_dir"          => "~/s3_mysql_backups",
    }

    if @s3config.nil?
      @s3config = @path_to_config.is_a?(Hash) ? defaults.merge(stringify_keys(@path_to_config)) : defaults.merge(YAML::load_file(@path_to_config))

      # Backcompat for gmail_* keys
      @s3config.keys.each do |key|
        @s3config[key.sub(/^gmail/, "mail")] = @s3config.delete(key)
      end
    end

    @s3config
  end

  def connect_to_s3
    @s3utils ||= S3Utils.new(config['s3_access_key_id'], config['s3_secret_access_key'], config['s3_bucket'], config['s3_server'], config['s3_region'])
  end

  # make the DB backup file
  def dump_db
    filename  = Time.now.strftime("#{@backup_dir}/#{@db_name}.%Y%m%d.%H%M%S.sql.gz")
    mysqldump = `which mysqldump`.to_s.strip
    `#{mysqldump} --host='#{config['dump_host']}' --user='#{config['dump_user']}' --password='#{config['dump_pass']}' '#{@db_name}' | gzip > #{filename}`
    @s3utils.store(filename, config['remote_dir'])
    filename
  end

  def ensure_backup_dir_exists
    @backup_dir = File.expand_path(config['backup_dir'])
    FileUtils.mkdir_p @backup_dir
  end

  def human_size(num, unit='bytes')
    units = %w(bytes KB MB GB TB PB EB ZB YB)
    if num <= 1024
      "#{"%0.2f"%num} #{unit}"
    else
      human_size(num/1024.0, units[units.index(unit)+1])
    end
  end

  def mail_notification(filename)
    return unless config['mail_to']
    stats = File.stat(filename)
    subject = "sql backup: #{@db_name}: #{human_size(stats.size)}"
    mail_from = config['mail_from'] ? config['mail_from'] : config['mail_user']

    content = []
    content << "From: #{mail_from}"
    content << "To: #{config['mail_to']}"
    content << "Subject: #{subject}"
    content << "Date: #{Time.now.rfc2822}"
    content << "\n#{File.basename(filename)}\n" # body
    content = content.join("\n")

    smtp = Net::SMTP.new(config["mail_domain"], config["mail_port"])
    smtp.enable_starttls unless config["mail_start_tls"] == false
    smtp.start(
      config["mail_domain"].to_s,
      config['mail_user'],
      (config['mail_pass'].nil? ? nil : config[:mail_pass].to_s),
      config['mail_authentication']
    ) do
      smtp.send_message(content, mail_from, config['mail_to'])
    end
  end

  # remove old backups
  #   - keep 30 days complete
  #   - keep 90 days weekly beyond that
  #   - keep only monthly after that
  def remove_old_backups
    today   = Date.today
    weekly  = (today - 30)
    monthly = (today - 120)

    path = File.expand_path(config['backup_dir'])

    Dir["#{path}/*.sql.gz"].each do |name|
      date     = name.split('.')[1]
      filedate = Date.strptime(date, '%Y%m%d')

      if filedate < weekly && filedate >= monthly
        # keep weeklies and also first of month
        unless filedate.wday == 0 || filedate.day == 1
          FileUtils.rm_f(name)
          @s3utils.delete(name)
        end
      elsif filedate < monthly
        # delete all old local files
        FileUtils.rm_f(name)

        # keep just first of month in S3
        unless filedate.day == 1
          @s3utils.delete(name)
        end
      end
    end # Dir.each
  end # remove_old_backups

  def stringify_keys(hash)
    hash.keys.each do |key|
      hash[key.to_s] = hash.delete(key)
    end
    hash
  end

end
