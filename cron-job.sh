LOG_PATH="/var/log/snapshot-copy/"
mkdir -p $LOG_PATH
LOG_FILE="$LOG_PATH`date '+%Y-%m-%d'.log`"

###############################################################################
# Duplicate this block to copy snapshot for mulitple volumes
###############################################################################
VOLUME_ID='vol-0629a13db343a19c0'
SOURCE_REGION='us-east-2'
TARGET_REGION='us-east-1'
/opt/snapshot-copy/copy-snapshot.sh \
    -v "$VOLUME_ID" \
    -s "$SOURCE_REGION" \
    -t "$TARGET_REGION" \
    >>$LOG_FILE 2>&1
###############################################################################