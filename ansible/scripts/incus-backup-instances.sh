#!/bin/bash

# ==============================================================================
# AUTOMATED INCUS INSTANCE BACKUP & ROTATION
# ==============================================================================
# This script iterates through all Incus Projects, finds all Instances (VMs/Containers),
# exports them (including their snapshots) to a backup directory, and deletes
# backups older than N versions.
# ==============================================================================

# --- CONFIGURATION ---
BACKUP_DIR="/mnt/backups/incus/instances"
RETENTION_COUNT=5
DATE_TAG=$(date +%Y-%m-%d_%H%M)
LOG_FILE="/var/log/incus-instance-backup.log"

mkdir -p "$BACKUP_DIR"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Incus Instance Backup..."

PROJECTS=$(incus project list --format csv -c n)

for PROJ in $PROJECTS; do
    PROJ=$(echo $PROJ | sed 's| \(current\)||')
    log "Scanning Project: $PROJ"
    INSTANCES=$(incus list --project "$PROJ" --format csv -c n)

    if [ -z "$INSTANCES" ]; then
        continue
    fi

    for INSTANCE in $INSTANCES; do
        BACKUP_NAME="${PROJ}_${INSTANCE}_${DATE_TAG}.tar.gz"
        BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

        log "Exporting instance: $INSTANCE (Project: $PROJ)..."

        if incus export "$INSTANCE" "$BACKUP_PATH" --project "$PROJ" --optimized-storage --instance-only > /dev/null 2>&1; then
            log "SUCCESS: Exported to $BACKUP_PATH"
            FILES_TO_DELETE=$(ls -tp "$BACKUP_DIR/${PROJ}_${INSTANCE}_"*.tar.gz 2>/dev/null | \
                              grep -v '/$' | \
                              tail -n +$((RETENTION_COUNT + 1)))
            if [ ! -z "$FILES_TO_DELETE" ]; then
                echo "$FILES_TO_DELETE" | while read -r OLD_BACKUP; do
                    log "ROTATION: Deleting old backup file: $OLD_BACKUP"
                    rm -- "$OLD_BACKUP"
                done
            fi
        else
            log "ERROR: Failed to export instance $INSTANCE from project $PROJ"
        fi
    done
done

log "Cleaning up backup permissions"
chown -R 1000:1000 /mnt/backups/incus

log "Instance backup run completed."
