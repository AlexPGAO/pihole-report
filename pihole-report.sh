#!/bin/bash

# === Pi-hole Log Report Script ===
# Safely analyze and report on log files without modifying anything.
# AlexPGAO v1.0

set -euo pipefail

LOG_DIR="/var/log/pihole"
DAYS_TO_KEEP=7

echo "=== Pi-hole Log Analysis Report ==="
echo "Analyzing logs in: $LOG_DIR"
echo "Current retention setting: $DAYS_TO_KEEP days"
echo ""

# Check if directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Log directory not found at $LOG_DIR"
    exit 1
fi

# Count uncompressed logs
uncompressed_count=$(find "$LOG_DIR" -type f -name "*.log" 2>/dev/null | wc -l)
uncompressed_size=$(find "$LOG_DIR" -type f -name "*.log" -exec du -ch {} + 2>/dev/null | grep total$ | awk '{print $1}')

# Count old uncompressed logs (older than 1 day)
old_uncompressed=$(find "$LOG_DIR" -type f -name "*.log" -mtime +1 2>/dev/null | wc -l)

# Count compressed logs
compressed_count=$(find "$LOG_DIR" -type f -name "*.gz" 2>/dev/null | wc -l)
compressed_size=$(find "$LOG_DIR" -type f -name "*.gz" -exec du -ch {} + 2>/dev/null | grep total$ | awk '{print $1}')

# Count old compressed logs (older than DAYS_TO_KEEP)
old_compressed=$(find "$LOG_DIR" -type f -name "*.gz" -mtime +$DAYS_TO_KEEP 2>/dev/null | wc -l)

# Count FTL logs
ftl_count=$(find "$LOG_DIR" -type f -name "FTL.log.*" 2>/dev/null | wc -l)
ftl_old=$(find "$LOG_DIR" -type f -name "FTL.log.*" -mtime +$DAYS_TO_KEEP 2>/dev/null | wc -l)

# Calculate total
total_files=$((uncompressed_count + compressed_count + ftl_count))
total_size=$(du -sh "$LOG_DIR" 2>/dev/null | awk '{print $1}')

# Display report
echo "📊 Current Status:"
echo "  Total log files: $total_files"
echo "  Total disk usage: $total_size"
echo ""
echo "📄 Uncompressed Logs (.log):"
echo "  Count: $uncompressed_count"
echo "  Size: ${uncompressed_size:-0}"
echo "  Older than 1 day: $old_uncompressed (would be compressed)"
echo ""
echo "🗜️  Compressed Logs (.gz):"
echo "  Count: $compressed_count"
echo "  Size: ${compressed_size:-0}"
echo "  Older than $DAYS_TO_KEEP days: $old_compressed (would be deleted)"
echo ""
echo "📝 FTL Logs:"
echo "  Count: $ftl_count"
echo "  Older than $DAYS_TO_KEEP days: $ftl_old (would be deleted)"
echo ""
echo "💾 Potential cleanup impact:"
if [ $old_uncompressed -gt 0 ] || [ $old_compressed -gt 0 ] || [ $ftl_old -gt 0 ]; then
    echo "  Files to compress: $old_uncompressed"
    echo "  Files to delete: $((old_compressed + ftl_old))"
else
    echo "  No files would be affected by cleanup"
fi
echo ""
echo "=== Report Complete ==="
