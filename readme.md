# Aws Snapshot Copy between regions

## Scope

1. Create bash script using aws-cli runing on Amazon Linux t3.nano instance
2. EC2 instance configured with a role and a policy to allow credential-less execution
3. Input parameters: source-volume-id, source-region, and target-region
4. The script to find and copy the latest snapshot available for the volume provided from the source region to the target region
5. The script is to remove older snapshots from the target region for the same volume after the copy is successful
6. The script to log output and errors to /var/log/snashot-copy/{yyyy-MM-dd}.log file and to delete logs older than X days configured in the script
7. Setup cron job to execute the script on a scheduled basis

## How to configure

1. Create new IAM Policy for EC2 Role with the plocy document: `./iam-policy.json`
1. Create new IAM Role with the policy created in the previous step
1. Launch a t3.nano instance of Amazon Linux
1. Assign the created IAM role to the new Amazon Linux instance to grant it required permissions without embedded credentials
1. Login to the newly created EC2 instance using SSH
1. Clone this repository:
```
sudo yum install git -i
git clone https://github.com/vkhazin/aws-cross-region-snapshot-copy
cd ./aws-cross-region-snapshot-copy`
```
1. Grant execution permissions: `chmod +x ./*.sh`
1. Update `./cron-job.sh` with desired volume id, source and target regions
1. Update `./setup-cron-job.sh` with the desired cron execution mask
1. Run the setup script `sudo ./setup-cron-job.sh`
1. Test the deployment by running: `sudo /opt/shapshot-copy/cron-job.sh`