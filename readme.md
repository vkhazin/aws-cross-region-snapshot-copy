# Aws Snapshot Copy between regions

## Scope

*  Create bash script using aws-cli runing on Amazon Linux t3.nano instance
2. EC2 instance configured with a role and a policy to allow credential-less execution, manually
3. Input parameters to the script: source-volume-id, source-region, and target-region
4. The script to find and copy the latest snapshot available for the volume provided from the source region to the target region
5. The script is to remove older snapshots from the target region for the same volume after the copy is successful
6. The script to log output and errors to /var/log/snashot-copy/{yyyy-MM-dd}.log file and to delete logs older than X days configured in the script
7. Automate setup of cron job to execute the script on a scheduled basis

## How to configure

*  Create new IAM Policy for EC2 Role with the plocy document: `./iam-policy.json`
*  Create new IAM Role with the policy created in the previous step
*  Launch a t3.nano instance of Amazon Linux
*  Assign the created IAM role to the new Amazon Linux instance to grant it required permissions without embedded credentials
*  Login to the newly created EC2 instance using SSH
*  Clone this repository:
```
sudo yum install git -y
git clone https://github.com/vkhazin/aws-cross-region-snapshot-copy
cd ./aws-cross-region-snapshot-copy`
```
*  Grant execution permissions: `chmod +x ./*.sh`
*  Update `./cron-job.sh` with desired volume id, source and target regions
*  Update `./setup-cron-job.sh` with the desired cron execution [mask](https://crontab.guru/)
*  Run the setup script `sudo ./setup-cron-job.sh`
*  Test the deployment by running: `sudo /opt/shapshot-copy/cron-job.sh`
*  Verify no errors have been logged: `sudo cat /var/log/snapshot-copy/$(date '+%Y-%m-%d'.log)`

## How to copy snapshot for multiple volumes

*  Duplicate lines in the `/opt/snapshot-copy/cron-job.sh` file