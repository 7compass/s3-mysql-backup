# S3 MySQL Backup

Simple backup of a MySQL database to Amazon S3, 
with email notification via Gmail.


## What does it do?

It makes a gzipped and timestamped local backup of the specified 
database using mysqldump.  The local backup is then copied to 
Amazon S3, and the results are emailed to the specified recipient.

Local and S3 backups are retained at this schedule:
- keep 30 days complete
- keep 90 days weekly beyond that
- keep only monthly after that

The email summary is a short email like:

    From:    my-user@gmail.com
    To:      my-recipient@example.com
    Date:    2012-12-22
    Subject: sql backup: my_database_name: 42.0 MB

    my_database_name.20121222.170134.sql.gz


## Configuration

Configure with a YAML file:

```yaml

# backup_dir            where to store the local backups
backup_dir: ~/s3_mysql_backups

# s3_access_key_id      your Amazon S3 access_key_id
# s3_secret_access_key  your Amazon S3 secret_access_key
# s3_bucket             your Amazon S3 bucket for the backups
# s3_server             OPTIONAL: your non-Amazon S3-compatible server
s3_access_key_id: my-key
s3_secret_access_key: my-secret
s3_bucket: my-bucket

# dump_host             OPTIONAL: your mysql host name
# dump_user             the database user for mysqldump
# dump_pass             the password for the dump user
dump_user: my-user
dump_pass: my-pass

# mail_to               where to send the backup summary email
mail_to: recipient@example.com

# Gmail credentials
gmail_user: me@gmail.com
gmail_pass: gmail-password

```


## Installation 

    gem install s3-mysql-backup


## Usage

From Ruby:

    S3MysqlBackup.new('database_name', '/path/to/s3-mysql-backup-config.yml').run

From command line:

    s3-mysql-backup database_name /path/to/s3-mysql-backup-config.yml

If you're using bundler:

    cd /path/to/my/app && bundle exec s3-mysql-backup database_name /path/to/s3-mysql-backup-config.yml


## Todo

Write tests


## Changelog
- 2013-06-01 1.2.2 Bugfix for passwords with spaces
- 2013-06-01 1.2.1 Added mysql host option (github.com/sagrimson)
- 2013-05-30 1.1.0 Added support for S3-compatible services, e.g. DreamObjects (thanks to John N. Milner - github.com/jnm)

## Credits

2008+ Seventh Compass
