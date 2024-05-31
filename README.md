# Daily Backup Script

## Purpose

This script serves as a tool to automate the backup process of files in a specified directory on a Linux system. It automates the task of backing up files that have been modified within the last 24 hours into a compressed archive, and optionally uploads them to an AWS S3 bucket.

## Features

- Automatically backs up files that have been modified within the last 24 hours.
- Compresses and archives the backup files.
- Optionally uploads the backup to an AWS S3 bucket.
- Logs all operations and errors into a log directory for easy monitoring and debugging.

## Requirements

- Bash (version 4.0 or higher)
- AWS CLI (configured with necessary permissions)
- `tar` and `date` utilities

## Usage

1. Clone this repository:
    ```bash
    git clone https://github.com/username/daily-backup-script.git
    cd daily-backup-script
    ```

2. Make the script executable:
    ```bash
    chmod +x backup.sh
    ```

3. Create a `.env` file in the project directory with the following content:
    ```env
    AWS_UPLOAD=true
    AWS_ACCESS_KEY_ID=your_aws_access_key_id
    AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key
    AWS_DEFAULT_REGION=your_aws_region
    S3_BUCKET=your_s3_bucket_name
    S3_KEY=your_s3_key_prefix
    ```

4. Run the script with the target and destination directories as arguments:
    ```bash
    ./backup.sh /path/to/target /path/to/destination
    ```

5. Check the `logs` directory for detailed logs of the backup process:
    ```bash
    cat logs/backup_YYYYMMDD_HHMMSS.log
    ```

## Recommended Usage

- It is recommended to use the script with caution on the inputted target and destination directories. Ensure you have selected the directories correctly to avoid any data loss or deletion.
- It is advisable to run the script using absolute path to the script, or moving the script to the `/usr/local/bin` directory for accessibility from anywhere.

## Automatic Scheduling with Cron Job

To schedule automatic backups using cron job, follow these steps:

1. Open the cron job with the command:
    ```bash
    crontab -e
    ```

2. Add the following line into the cron job file to run the backup every day at 00:00:
    ```bash
    0 0 * * * /path/to/backup.sh /path/to/target /path/to/destination
    ```

Make sure to replace `/path/to/backup.sh`, `/path/to/target`, and `/path/to/destination` with the appropriate locations of the backup script, target directory, and destination directory, respectively, according to your system.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

