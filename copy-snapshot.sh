#!/bin/bash 

TIMEOUT=600  # Timeout to wait the snapshot copy. In seconds
REMOVE_LOGS_OLDER_THAN=30 # in days

LOG_PATH="/var/log/snapshot-copy"
LOG_FILE=`date '+%Y-%m-%d'.log`

while getopts v:s:t: option
do 
 case "${option}" in 
    v) VOLUME_ID=${OPTARG};; 
    s) SOURCE_REGION=${OPTARG};; 
    t) TARGET_REGION=${OPTARG};;
    :) echo "Error: -${OPTARG} requires an argument."
       exit 1                          
       ;;
    *) echo -e "Usage: ./copy-snapshot.sh -v VOLUME_ID -s SOURCE_REGION -t TARGET_REGION"
       exit 1
       ;;
 esac 
done

if [[ -z $VOLUME_ID || -z $TARGET_REGION || -z $SOURCE_REGION ]]; then
    echo -e "Usage: cmd -v VOLUME_ID -s SOURCE_REGION -t TARGET_REGION"
    exit 1
fi

set -e

mkdir -p $LOG_PATH
# Get last  snapshot ID from volume with $VOLUME_ID
get_last_snapshot () {
    VOLUME_ID=$1
    last_snapshot=`aws ec2 describe-snapshots \
        --filter Name=volume-id,Values=$VOLUME_ID\
        --query="reverse(sort_by(Snapshots,&StartTime))[0].SnapshotId"\
        --output text\
        --region $SOURCE_REGION`
}

copy_snapshot () {
    last_snapshot=$1

    copy_snapshot_id=`aws ec2 copy-snapshot \
        --region $TARGET_REGION \
        --source-region $SOURCE_REGION \
        --source-snapshot-id $last_snapshot \
        --description "This snapshot is a copy of $last_snapshot from $SOURCE_REGION. region"\
        --query="SnapshotId"\
        --output text`

    echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Snapshot ID $TARGET_REGION=$copy_snapshot_id" | tee -a $LOG_PATH/$LOG_FILE
    echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Checking snapshot migration progress..." | tee -a $LOG_PATH/$LOG_FILE
    for i in `seq 1 10`; do
       status=`aws ec2 describe-snapshots \
            --filter Name=snapshot-id,Values=$copy_snapshot_id\
            --region $TARGET_REGION\
            --query="Snapshots[0].State"\
            --output text`
        if [[ $status == "completed" ]]; then
            echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Snapshot migration has finished successfully." | tee -a $LOG_PATH/$LOG_FILE
            aws ec2 create-tags \
                --resources $copy_snapshot_id\
                --tags Key=source_volume,Value=$VOLUME_ID\
                --region $TARGET_REGION
            break
        else
            echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Snapshot migration status: $status..." | tee -a $LOG_PATH/$LOG_FILE
        fi
        if [[ $i == 10 ]]; then
            echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Timeout has occured! Migration of a snapshot took too long" | tee -a $LOG_PATH/$LOG_FILE
            exit 1    
        fi
        let "seconds = $TIMEOUT / 10"
        sleep $seconds 
    done
}

remove_snapshot_different_than () {
    copy_snapshot_id=$1
    VOLUME_ID=$2

    old_snapshots=`aws ec2 describe-snapshots \
        --filter Name=tag-value,Values=$VOLUME_ID\
        --region $TARGET_REGION\
        --query "[Snapshots][*][?SnapshotId != '$copy_snapshot_id'].SnapshotId"\
        --output text`

    for o in $old_snapshots; do
        echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Removing snapshot $o from region $TARGET_REGION..." | tee -a $LOG_PATH/$LOG_FILE
        response=`aws ec2 delete-snapshot\
            --snapshot-id $o\
            --region $TARGET_REGION`
        if [[ $response == "" ]]; then
            echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Snapshot $o has been removed successfully" | tee -a $LOG_PATH/$LOG_FILE
        fi
    done
}


# Main
echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Getting snapshot ID for volume $VOLUME_ID in region $SOURCE_REGION" | tee -a $LOG_PATH/$LOG_FILE
get_last_snapshot $VOLUME_ID

if [[ $last_snapshot == "None" ]]; then
    echo $(date '+%Y-%m-%d %H:%M:%S:%N') "No snapshot was found for the volume $VOLUME_ID in the region $SOURCE_REGION" | tee -a $LOG_PATH/$LOG_FILE
    exit 1
else
    echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Last snapshot for the volume $VOLUME_ID in the region $SOURCE_REGION is $last_snapshot" | tee -a $LOG_PATH/$LOG_FILE
fi

echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Copying snapshot ID $last_snapshot to region $TARGET_REGION..." | tee -a $LOG_PATH/$LOG_FILE
copy_snapshot $last_snapshot

echo $(date '+%Y-%m-%d %H:%M:%S:%N') "Removing snapshots for volume $VOLUME_ID in region $TARGET_REGION different than $copy_snapshot_id" | tee -a $LOG_PATH/$LOG_FILE
remove_snapshot_different_than $copy_snapshot_id $VOLUME_ID

find $LOG_PATH -type f -name "*.log" -mtime +$REMOVE_LOGS_OLDER_THAN -exec rm {} \;