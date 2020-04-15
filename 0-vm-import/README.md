# Create Private OS Image for AWS

## 1. Create VirtualBox CentOS Image
1. Install OS with ISO File
2. Export to OVA file
### 1.1 VM Configuration
Disk Image: VMDK, Static allocation
CPU count/Memory: Don't consider (This is managed by AWS Instance)
- Just set for installation speed
### 1.2 OS Configuration
No extra user
DHCP network configuration

### 1.3 VM Export
After installtaion OS, do export from VirtualBox menu
Select "Open Virtualization Format 2.0"

## 2. Upload image to S3
### 2.1 Create group/user in AWS
First, create group with some permmistions( In this case, I create `vmimport` group)
- AmazonEC2FullAccess
- IAMFullAccess
- AmazonS3FullAccess
- AWSImportExportFullAccess
- VMImportExportRoleForAWSConnector

Last, Create User with created group permissions
- In this case, I create `vmimport` user

## 3. Create VM import service Role
### 3.1 Create AWS CLI
```
root@cloud:/home/kangdw# pip3 install awscli --user
Collecting awscli
  Using cached https://files.pythonhosted.org/packages/7b/bf/ee7ef635c19d5520f1098d37b39d249b19aa4d36504136c16a1ba64cf476/awscli-1.16.290-py2.py3-none-any.whl
  Requirement already satisfied: botocore==1.13.26 in /root/.local/lib/python3.8/site-packages (from awscli) (1.13.26)
  Requirement already satisfied: rsa<=3.5.0,>=3.1.2 in /root/.local/lib/python3.8/site-packages (from awscli) (3.4.2)
  Requirement already satisfied: colorama<0.4.2,>=0.2.5; python_version != "2.6" and python_version != "3.3" in /root/.local/lib/python3.8/site-packages (from awscli) (0.4.1)
  Requirement already satisfied: docutils<0.16,>=0.10 in /root/.local/lib/python3.8/site-packages (from awscli) (0.15.2)
  Requirement already satisfied: PyYAML<5.2,>=3.10; python_version != "2.6" and python_version != "3.3" in /root/.local/lib/python3.8/site-packages (from awscli) (5.1.2)
  Requirement already satisfied: s3transfer<0.3.0,>=0.2.0 in /root/.local/lib/python3.8/site-packages (from awscli) (0.2.1)
  Requirement already satisfied: python-dateutil<2.8.1,>=2.1; python_version >= "2.7" in /root/.local/lib/python3.8/site-packages (from botocore==1.13.26->awscli) (2.8.0)
  Requirement already satisfied: jmespath<1.0.0,>=0.7.1 in /root/.local/lib/python3.8/site-packages (from botocore==1.13.26->awscli) (0.9.4)
  Requirement already satisfied: urllib3<1.26,>=1.20; python_version >= "3.4" in /root/.local/lib/python3.8/site-packages (from botocore==1.13.26->awscli) (1.25.7)
  Requirement already satisfied: pyasn1>=0.1.3 in /root/.local/lib/python3.8/site-packages (from rsa<=3.5.0,>=3.1.2->awscli) (0.4.8)
  Requirement already satisfied: six>=1.5 in /usr/local/python3/lib/python3.8/site-packages (from python-dateutil<2.8.1,>=2.1; python_version >= "2.7"->botocore==1.13.26->awscli) (1.13.0)
  Installing collected packages: awscli
  Successfully installed awscli-1.16.290
```
### 3.2 Configure AWS user
```bash
root@cloud:/home/kangdw# aws configure
AWS Access Key ID [****************TQGS]:
AWS Secret Access Key [****************DXyK]:
Default region name [ap-northeast-2]:
Default output format [None]:
```

### 3.3 Upload OVA file to S3
Upload OVA file created by VirtualBox to S3 Bucket
In this case, I uploaded file in `S3://centos.image.com/centos76/centos7.6-ext4.ova`
## 4. Import VM Image
### 4.1 Create Role for VM Import Service
create trust-policy.json file
```
root@cloud:/home/kangdw#  vim trust-policy.json

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "vmie.amazonaws.com" },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals":{
          "sts:Externalid": "vmimport"
        }
      }
    }
  ]
}
```
Do cmd
```
root@cloud:/home/kangdw# aws iam create-role --role-name vmimport --assume-role-policy-document file://trust-policy.json
```
Create detail role
```json
root@cloud:/home/kangdw# vim role-policy.json


{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::centos.image.com*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::centos.image.com*"
                                                                                                                                                                                              ]
    },
    {
      "Effect": "Allow",
      "Action":[
        "ec2:ModifySnapshotAttribute",
        "ec2:CopySnapshot",
        "ec2:RegisterImage",
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
```
Make role policy with below command
```

root@cloud:/home/kangdw# aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://role-policy.json

{
    "Role": {
        "Path": "/",
        "RoleName": "vmimport",
        "RoleId": "AROAWKTJ2Y3EXZ2B3QVSF",
        "Arn": "arn:aws:iam::435087394505:role/vmimport",
        "CreateDate": "2019-11-22T05:32:09Z",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "vmie.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole",
                    "Condition": {
                        "StringEquals": {
                            "sts:Externalid": "vmimport"
                        }
                    }
                }
            ]
        }
    }
}
```
### 4.2 VM Image Importing
Create Image Information OS file in S3
```
root@cloud:/home/kangdw# vim container.json

[
  {
    "Description": "CentOS 7.6 OVA",
    "Format": "ova",
    "UserBucket": {
      "S3Bucket": "centos.image.com",
      "S3Key": "centos76/centos7.6-ext4.ova"
    }
  }
]
```

Import VM Image
```
root@cloud:/home/kangdw# aws ec2 import-image --description "CentOS 7.6" --disk-containers file://container.json
{
    "Description": "CentOS 7.6",
    "ImportTaskId": "import-ami-0a4179852aa7ed656",
    "Progress": "2",
    "SnapshotDetails": [
        {
            "DiskImageSize": 0.0,
            "Format": "OVA",
            "UserBucket": {
                "S3Bucket": "centos.image.com",
                "S3Key": "centos76/centos7.6-ext4.ova"
            }
        }
    ],
    "Status": "active",
    "StatusMessage": "pending"
}
```

### 4.3 Check Importing progress
Step of Importing is below
- pending
- converting
- updating
- active booting
- active booted
- active preparing ami
- complete
You can check with command
```
# Use your impoart ami (ex import-ami-0a4179852aa7ed656
# You can find the ID from output of `aws ec2 import-image` command
root@cloud:/home/kangdw# aws ec2 describe-import-image-tasks --import-task-ids import-ami-0a4179852aa7ed656
{
    "ImportImageTasks": [
        {
            "Architecture": "x86_64",
            "Description": "CentOS 7.6",
            "ImageId": "ami-015ef863a6393eccd",
            "ImportTaskId": "import-ami-0a4179852aa7ed656",
            "LicenseType": "BYOL",
            "Platform": "Linux",
            "SnapshotDetails": [
                {
                    "DeviceName": "/dev/sda1",
                    "DiskImageSize": 892038144.0,
                    "Format": "VMDK",
                    "SnapshotId": "snap-03b2ff11bc310e834",
                    "Status": "completed",
                    "UserBucket": {
                        "S3Bucket": "centos.image.com",
                        "S3Key": "centos76/centos7.6-ext4.ova"
                    }
                }
            ],
            "Status": "completed"
        }
    ]

```
