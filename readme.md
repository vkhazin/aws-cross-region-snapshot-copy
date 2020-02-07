# Aws Snapshot Copy between regions

## Scope

1. Create bash script using aws-cli runing on Amazon Linux t3.nano instance
2. EC2 instance configured with a role and a policy to allow credential-less execution
3. input parameters: source-volume-id, source-region, and target-region
4. The script to find and copy the latest snapshot available for the volume provided from the source region to the target region
5. The script is to remove older snapshots from the target region for the same volume after the copy is successful
6. The script to log output and errors to /var/log/snashot-copy/{yyyy-MM-dd}.log file and to delete logs older than X days configured in the script

## How to run the script

* Grant execution permissions: `chmod +x ./*.sh`
* Execute in a terminal: 
```
VOLUME_ID='vol-0629a13db343a19c0'
SOURCE_REGION='us-east-2'
TARGET_REGION='us-east-1'
./copy-snapshot.sh -v "$VOLUME_ID" -s "$SOURCE_REGION" -t "$TARGET_REGION"
```