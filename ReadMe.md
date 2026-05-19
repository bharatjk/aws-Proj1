aws-Proj1/                          ← Your Git repo root
├── .github/
│   └── workflows/
│       └── terraform.yml           ← We'll need to UPDATE this
├── P0/                             ← Phase 1: IAM (your existing folder)
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   └── ...
├── VPC-Compute/                    ← Phase 2: Networking (NEW folder)
│   ├── backend.tf
│   ├── variables.tf
│   └── ...
├── Phase3-Compute/                 ← Phase 3: EC2, Lambda (future)
│   └── ...
└── Phase4-Storage/                 ← Phase 4: S3, RDS (future)
    └── ...

# S3 Bucket — stores the actual state
kakkad-tf-state/
├── phase1/terraform.tfstate    ← Phase 1 IAM state
├── phase2/terraform.tfstate    ← Phase 2 VPC state
└── phase3/terraform.tfstate    ← Phase 3 Compute state (future)

# DynamoDB Table — provides locking (prevents conflicts)
The table has ONE row per active terraform operation:
LockID                                                                        Info
(Primary Key) Timestampkakkad-tf-state/phase1/terraform.tfstate-md5         {"ID":"abc123","Operation":"OperationTypeApply","Who":"bharatjk@hostname","Version":"1.7.0"}2025-05-18T...

