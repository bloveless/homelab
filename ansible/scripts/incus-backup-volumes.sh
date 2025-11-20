#!/bin/bash

# ==============================================================================
# AUTOMATED INCUS VOLUME BACKUP & ROTATION
# ==============================================================================
# This script iterates through all Incus storage pools, finds "custom" volumes,
# exports them to a backup directory, and deletes backups older than N versions.
# ==============================================================================

# --- CONFIGURATION ---
BACKUP_DIR="/mnt/backups/incus/volumes"
RETENTION_COUNT=5
DATE_TAG=$(date +%Y-%m-%d_%H%M)
LOG_FILE="/var/log/incus-volume-backup.log"

mkdir -p "$BACKUP_DIR"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Incus Volume Backup..."

POOLS=$(incus storage list --format csv -c n)

for POOL in $POOLS; do
    VOLUMES=$(incus storage volume list "$POOL" type=custom --all-projects --format csv -c n)

    if [ -z "$VOLUMES" ]; then
        continue
    fi

    for VOLUME in $VOLUMES; do
        BACKUP_NAME="${POOL}_${VOLUME}_${DATE_TAG}.tar.gz"
        BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
        
        log "Exporting volume: $VOLUME (Pool: $POOL)..."
        if incus storage volume export "$POOL" "$VOLUME" "$BACKUP_PATH" --optimized-storage --volume-only > /dev/null 2>&1; then
            log "SUCCESS: Exported to $BACKUP_PATH"
            FILES_TO_DELETE=$(ls -tp "$BACKUP_DIR/${PROJ}_${VOLUME}_"*.tar.gz 2>/dev/null | \
                              grep -v '/$' | \
                              tail -n +$((RETENTION_COUNT + 1)))
            if [ ! -z "$FILES_TO_DELETE" ]; then
                echo "$FILES_TO_DELETE" | while read -r OLD_BACKUP; do
                    log "ROTATION: Deleting old backup file: $OLD_BACKUP"
                    rm -- "$OLD_BACKUP"
                done
            fi
        else
            log "ERROR: Failed to export volume $VOLUME from pool $POOL"
        fi
    done
done

log "Cleaning up backup permissions"

chown -R 1000:1000 /mnt/backups/incus

log "Backup run completed."
