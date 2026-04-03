# Structure
```bash
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── alb/
│   ├── rds/
│   └── bastion/
└── bootstrap/          ← S3 + DynamoDB state backend setup
    └── main.tf
```

- [x] Bootstrap — S3 state bucket + DynamoDB lock table
- [x] VPC module — VPC, public/private subnets, IGW, NAT gateway, route tables
- [ ] Security Groups — for ALB, EC2, RDS, and Bastion
- [ ] Bastion module — jump host for SSH access to private EC2
- [ ] EC2 module — app server in private subnet
- [ ] ALB module — load balancer in public subnet routing to EC2
- [ ] RDS module — PostgreSQL in private subnet
- [ ] Environment wiring — dev and prod environment configs