set -e
mkdir -p /opt/snapshot-copy
cp ./copy-snapshot.sh /opt/snapshot-copy
cp ./cron-job.sh /opt/snapshot-copy
SCHEDULE='*/1 * * * *' #https://crontab.guru/
echo "$SCHEDULE root /opt/shapshot-copy/cron-job.sh"
