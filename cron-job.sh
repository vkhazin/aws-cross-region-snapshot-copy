VOLUME_ID='vol-0629a13db343a19c0'
SOURCE_REGION='us-east-2'
TARGET_REGION='us-east-1'

LOG_PATH="/var/log/snapshot-copy"
LOG_FILE=`date '+%Y-%m-%d'.log`
mkdir -p $LOG_PATH

/opt/snapshot-copy/copy-snapshot.sh -v "$VOLUME_ID" -s "$SOURCE_REGION" -t "$TARGET_REGION" | tee -a $LOG_PATH/$LOG_FILE