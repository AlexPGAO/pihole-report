# Pi-hole Log Management Scripts

A pair of lightweight Bash scripts designed to manage Pi-hole logs on Raspberry Pi systems, helping reduce SD card wear and maintain optimal storage usage.

## 📋 Overview

These scripts help you monitor and maintain your Pi-hole's log files by:
- **Analyzing** current log storage usage without making changes
- **Cleaning** old logs automatically with compression and rotation

Perfect for Raspberry Pi users who want to extend SD card lifespan by managing log file growth.

## 🚀 Features

### `pihole-report.sh` (Analysis Tool)
- **Read-only analysis** - Never modifies your files
- Counts uncompressed, compressed, and FTL logs
- Shows total disk usage
- Reports which files would be affected by cleanup
- Provides a "dry-run" view before cleaning

### `pihole-clean.sh` (Cleanup Tool)
- Compresses logs older than 1 day
- Removes compressed logs older than 7 days (configurable)
- Cleans FTL logs automatically
- Reduces SD card wear through intelligent log rotation

## 📦 Installation

### Option 1: Direct Download
```bash
# Download the scripts
wget https://raw.githubusercontent.com/AlexPGAO/pihole-log-manager/main/pihole-report.sh
wget https://raw.githubusercontent.com/AlexPGAO/pihole-log-manager/main/pihole-clean.sh

# Make them executable
chmod +x pihole-report.sh pihole-clean.sh
```

### Option 2: Clone Repository
```bash
git clone https://github.com/AlexPGAO/pihole-log-manager.git
cd pihole-log-manager
chmod +x *.sh
```

### Option 3: Manual Transfer (Windows to Pi)
```bash
# Using pscp (PuTTY)
pscp pihole-report.sh user@192.168.0.10:/home/user/
pscp pihole-clean.sh user@192.168.0.10:/home/user/

# Then SSH in and make executable
ssh user@192.168.0.10
chmod +x pihole-report.sh pihole-clean.sh
```

## 🔧 Usage

### Analyze Logs First (Recommended)
Always run the report script before cleaning to see what will be affected:

```bash
sudo ./pihole-report.sh
```

**Sample Output:**
```
=== Pi-hole Log Analysis Report ===
Analyzing logs in: /var/log/pihole
Current retention setting: 7 days

📊 Current Status:
  Total log files: 42
  Total disk usage: 156M

📄 Uncompressed Logs (.log):
  Count: 15
  Size: 89M
  Older than 1 day: 12 (would be compressed)

🗜️  Compressed Logs (.gz):
  Count: 24
  Size: 45M
  Older than 7 days: 8 (would be deleted)

📝 FTL Logs:
  Count: 3
  Older than 7 days: 1 (would be deleted)

💾 Potential cleanup impact:
  Files to compress: 12
  Files to delete: 9

=== Report Complete ===
```

### Clean Logs
Once you're satisfied with the report, run the cleanup:

```bash
sudo ./pihole-clean.sh
```

## ⚙️ Configuration

Edit the `DAYS_TO_KEEP` variable in both scripts to change retention period:

```bash
# Default: Keep compressed logs for 7 days
DAYS_TO_KEEP=7

# Keep for 14 days instead
DAYS_TO_KEEP=14

# Keep for 30 days
DAYS_TO_KEEP=30
```

## ⏰ Automation with Cron

Set up automatic weekly cleaning:

```bash
# Edit crontab
sudo crontab -e

# Add this line to run every Sunday at 3 AM
0 3 * * 0 /home/theshefu/pihole-clean.sh >> /var/log/pihole-cleanup.log 2>&1
```

**Other scheduling options:**
```bash
# Daily at 2 AM
0 2 * * * /home/theshefu/pihole-clean.sh

# Every 3 days at midnight
0 0 */3 * * /home/theshefu/pihole-clean.sh

# Monthly on the 1st at 1 AM
0 1 1 * * /home/theshefu/pihole-clean.sh
```

## 📊 What Gets Cleaned

| File Type | Action | Timing |
|-----------|--------|--------|
| `*.log` (uncompressed) | Compressed with gzip | After 1 day |
| `*.gz` (compressed) | Deleted | After DAYS_TO_KEEP (default: 7 days) |
| `FTL.log.*` | Deleted | After DAYS_TO_KEEP (default: 7 days) |

## 🛡️ Safety Features

- **Error handling**: Scripts exit on errors (`set -euo pipefail`)
- **Non-destructive analysis**: Report script is completely read-only
- **Targeted cleanup**: Only removes files matching specific patterns
- **Preservation**: Current day logs are never touched

## 🔍 Troubleshooting

### Permission Denied
```bash
# Make sure scripts are executable
chmod +x pihole-report.sh pihole-clean.sh

# Run with sudo (required for /var/log/pihole access)
sudo ./pihole-report.sh
```

### Directory Not Found
If you get "Error: Log directory not found", verify your Pi-hole installation:
```bash
ls -la /var/log/pihole
```

### No Files Being Cleaned
- Check that logs actually exist and are old enough
- Verify the modification time with: `ls -lth /var/log/pihole`
- Adjust `DAYS_TO_KEEP` if needed

## 📝 Requirements

- Raspberry Pi (or any Linux system) running Pi-hole
- Bash shell
- Root/sudo access
- Standard utilities: `find`, `gzip`, `du`, `awk`

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add improvement'`)
4. Push to branch (`git push origin feature/improvement`)
5. Open a Pull Request

## 📄 License

MIT License - See LICENSE file for details

## ⚠️ Disclaimer

These scripts modify system log files. While designed to be safe:
- Always test in a non-production environment first
- Review the report output before running cleanup
- Maintain backups of important data
- Use at your own risk

## 👤 Author

**AlexPGAO** - v1.0

## 🙏 Acknowledgments

- Built for the Pi-hole community
- Designed to extend Raspberry Pi SD card lifespan
- Inspired by best practices in log rotation and management

---

**⭐ Found this helpful? Give it a star!**

**🐛 Found a bug? Open an issue!**

**💡 Have an idea? Submit a PR!**
