#!/usr/bin/env python3

import os
import sys
import re
import subprocess
from typing import List, Dict, Tuple
from pathlib import Path

class InfraProvisioner:

    def __init__(self):
        self.terraform_dir = Path(__file__).parent.resolve().parent / "terraform"
        self.s3_buckets = None
        self.iam_users = None
        self.team_name = None
        self.validate_inputs()

    def validate_inputs(self):
        self.team_name = os.getenv('TEAM_NAME', '').strip()
        s3_buckets_input = os.getenv('S3_BUCKETS', '').strip()
        iam_users_input = os.getenv('IAM_USERS', '').strip()
        self.action = os.getenv('ACTION', '')
        possible_actions = ['plan', 'apply', 'destroy']

        if not self.action or self.action not in possible_actions:
            raise ValueError(f"Invalid action: {self.action}")

        if self.team_name != "N/A":
            self.team_name = self.team_name.replace(r"\s+", "")

        if s3_buckets_input:
            self.s3_buckets = [bucket.strip() for bucket in s3_buckets_input.split(",")]

        if iam_users_input:
            self.iam_users = [user.strip() for user in iam_users_input.split(",")]


    def prepare_terraform(self):
        tfvars_path = self.terraform_dir / "terraform.tfvars"
        with open(tfvars_path, "w") as tfvars:
            tfvars.write(f'team_name = "{self.team_name}"\n\n')
            if self.s3_buckets:
                tfvars.write('s3_buckets = [\n')
                for bucket in self.s3_buckets:
                    tfvars.write(f'"{self.team_name}-{bucket}",\n')
                tfvars.write(']\n\n')
            else:
                tfvars.write('s3_buckets = []\n\n')

            if self.iam_users:
                tfvars.write('iam_users = [\n')
                for user in self.iam_users:
                    tfvars.write(f'  "{user}",\n')
                tfvars.write(']\n\n')
            else:
                tfvars.write('iam_users = []\n\n')

        if not tfvars_path.exists():
            print("ERROR: Failed to create terraform.tfvars!")
            sys.exit(1)
        

    # def get_terraform_targets(self) -> List[str]:
    #     targets = []
        
    #     if self.s3_buckets:
    #         targets.append('-target=module.s3')
    #     # if self.iam_users:
    #     #     targets.append('-target=module.iam_users')
        
    #     return targets
    
    def run_terraform(self, command: List[str]) -> bool:
        try:
            result = subprocess.run(
                command,
                cwd=self.terraform_dir,
                check=True,
                text=True
            )
            return True
        except subprocess.CalledProcessError as e:
            print(f"Terraform command failed: {e}")
            return False

    def execute_terraform(self):
        if not self.run_terraform(['terraform', 'init']):
            sys.exit(1)
        # Always print the plan
        self.run_terraform(['terraform', 'plan'])
        if self.action == 'plan':
            return
        elif self.action in ('apply', 'destroy'):
            tf_cmd = 'apply' if self.action == 'apply' else 'destroy'
            if not self.run_terraform(['terraform', tf_cmd, '-auto-approve']):
                sys.exit(1)
            if self.action == 'apply':
                print("Infrastructure provisioned successfully!")
            else:
                print("Infrastructure destroyed")

    def provision_infra(self):
        self.prepare_terraform()
        self.execute_terraform()


def main():
    provisioner = InfraProvisioner()
    provisioner.provision_infra()

if __name__ == '__main__':
    main()