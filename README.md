
# s3-automated-backup

Shell scripts for automatically backing up files to AWS S3

### Pre-requisites:
* AWS S3 bucket. Bucket should be set to private. Other settings can be left at default
* AWS access token with the following permissions to your S3 bucket. See iam_policy.json:
  * "s3:PutObject",
  * "s3:GetObject",
  * "s3:DeleteObject",
  * "s3:PutObjectAcl",
  * "s3:ListBucket",
  * "s3:GetBucketLocation"

* For security purposes, it's highly recommended to create a new IAM user/role for this access token, and limit its scope to your S3 bucket. Avoid using access tokens with broad access, in order to comply with principle of least privilege.

* Recommended: Syncthing to sync files between devices. <br> https://syncthing.net/ <br> Having on-site redundancy in addition to a cloud backup is ideal, and Syncthing makes it very /easy.

* Device that has reliable network access. Instructions are provided for Windows and Linux.

### AWS CLI setup:

1. Install AWS CLI tools https://github.com/aws/aws-cli
2. Run aws configure. Configure using the S3 access token generated earlier

### Scheduling shell scripts on Linux 
We'll be using cron to schedule jobs. See https://crontab.guru/ for help with cron syntax

1. Run the following terminal command to open the cron editor 
> crontab -e
2. Create a new line with the following command: <br>
3. If device is restarted every day: 
> @reboot aws s3 sync /home/{user}/{sync folder} s3://{bucket name}
4. If device is running always-on, this will run the aws sync command every day at midnight: 
> 0 0 * * * aws s3 sync /home/{user}/{sync folder} s3://{bucket name}

### Scheduling shell scripts on Windows 10 Pro

1. Create a new powershell file (.ps1 file extension) and place it somewhere your user has access to, e.g. your Desktop
2. In the powershell file, add the following:
> aws s3 sync C:\Users\{user}\Desktop\{sync folder} s3://{bucket name} |
> Out-File -Append -FilePath C:\Users\{user}\Desktop\s3-sync-log.txt
3. If device is restarted frequently, i.e. every day:
	1. Search for "gpedit" and run Edit Group Policy
	2. Navigate to "User Configuration > Windows Settings > Scripts (Logon/Logoff)"
	3. Select Logon
	4. Click Add...
	5. Click Browse... and specify the location of your powershell script created in step 1.
	6. Click OK then Apply then OK
4. If device is running aways-on:
	1. Search for and run "Task Scheduler"
	2. Select "Create Task..." in the right panel
	3. Name your task, then select Run whether user is logged on or not
	4. Select Triggers tab
	5. Click New...
	6. Schedule the task to run when and how frequently as desired
	7. Click OK
	8. Select Actions tab
	9. Click New...
	10. Select action "Start a program"
	11. Click Browse
	12. Select the powershell.exe program, usually located at C:\Windows\System32\WindowsPowershell\v1.0\powershell.exe
	13. Add the following argument: "-File {path to your powershell script from step 1}"
	14. Click OK then OK
