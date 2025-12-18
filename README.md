# AWS Shell

A collection of AWS CLI utility scripts for managing AWS resources.

## Overview

This repository contains various shell scripts to simplify common AWS operations, including EC2 management, region switching, EKS AMI updates, and more.

## Prerequisites

- AWS CLI installed and configured
- Bash/Zsh shell
- Valid AWS credentials configured

## Scripts

### aws-shell.sh

Main utility script containing functions for:

- **ec2_list()** - List EC2 instances with details (Name, Environment, IP, Type, AZ)
- **aws_region_all_name()** - Display all AWS regions with their long names
- **aws_az_list()** - List availability zones in current region
- **aws_rule()** - Find security groups with 0.0.0.0/0 access
- **aws_elb_Get()** - List load balancers
- **aws_elb_Tag()** - Display target groups details
- **aws_ecr_list()** - List ECR repositories
- **aws_route53_list_host_zone()** - List Route53 hosted zones
- **aws_keypair_list()** - List EC2 key pairs

### menu.sh

Interactive menu generator for navigating AWS operations.

### aws-region-change.sh

Switch between AWS regions easily.

### awsRegion.sh

Region management utilities.

### aws-eks-ami.sh

EKS AMI update utilities.

### find-orphan-ebs.sh

Find and list orphaned EBS volumes.

### rds.sh

RDS database management utilities.

### pulumi.sh

Pulumi infrastructure management scripts.

### test.sh

Testing utilities.

## Usage

### Basic Usage

Source the main script to use the functions:

```bash
source aws-shell.sh

# List EC2 instances
ec2_list

# List all AWS regions
aws_region_all_name

# List ECR repositories
aws_ecr_list
```

### Interactive Menu

Run the menu script for an interactive interface:

```bash
./menu.sh
```

## Environment Variables

Set your AWS region:

```bash
export AWS_REGION=us-east-1
```

## License

MIT

## Contributing

Feel free to submit issues and pull requests.
