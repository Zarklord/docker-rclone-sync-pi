#!/bin/sh

echo "INFO: Starting sync.sh pid $$ $(date)"

if [ `lsof | grep $0 | wc -l | tr -d ' '` -gt 1 ]
then
  echo "WARNING: A previous sync is still running. Skipping new sync command."
else

echo $$ > /tmp/sync.pid

if test "$(ls /data)"; then
  # the source directory is not empty
  # it can be synced without clear data loss
  
  echo "INFO: Startin rclone dedupe --dedupe-mode newest $SYNC_DEST $RCLONE_OPTS"
  rclone dedupe --dedupe-mode newest $SYNC_DEST $RCLONE_OPTS
  
  echo "INFO: Starting rclone sync /data $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS"
  rclone sync /data $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS

  if [ -z "$CHECK_URL" ]
  then
    echo "INFO: Define CHECK_URL with https://healthchecks.io to monitor sync job"
  else
    wget $CHECK_URL -O /dev/null
  fi
else
  echo "WARNING: Source directory is empty. Skipping sync command."
fi

rm -f /tmp/sync.pid

fi