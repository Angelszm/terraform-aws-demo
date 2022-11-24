## Terraforming-AWS-Services

CloudFormation or Terraform
Terraform 
```
✅ Cloud Support and other service support: Opensource, Support multi-clouds, e.g., Azure, GCP, and other services Jenkins, Kubernetes, etc.
✅ Module support: You can create a module to reuse the template.
✅ Command line: Terraform cli has simple syntax(terraform init)
✅ Language support: Support Hashicorp configuration
Ref from : Linkedin
```


## AWS Resources

### Basic Terraforming 
- [x] S3 Website Hosting
- [x] Cloudfront Distribution
- [ ] Route53
- [x] VPC
- [x] EC2
- [x] ECR Docker Image
- [x] ECS Cluster & Service {Fargate}
- [x] ECS Task Definition
- [ ] Attach Load Balance to Fargate
- [x] SQS
- [x] IoT Automation
- [x] EKS
- [x] Taint Docker


```
$ terraform state list 
$ terraform state show -- 
$ terraform show
```

## Postgres Setup on EC2 
https://www.pedroalonso.net/blog/using-terraform-to-automate-the-deployment-of-postgresql-to-ec2

### ECS
- https://towardsaws.com/create-ecs-cluster-using-terraform-7b18a2cbc0ba
- https://medium.com/ci-t/9-steps-to-ssh-into-an-aws-fargate-managed-container-46c1d5f834e2
- https://particule.io/en/blog/cicd-ecr-ecs/ (with Terraform)
- https://webcaptioner.com/blog/2017/12/deploy-from-gitlab-to-aws-fargate/
- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html


Terraform Notes: 
```
Open-Source, Declarative and Cloud Agnostic
Idempotency & Consistent

```


Infrastructure Lifecycle
- Reliability 
- Manageability 
- Sensibility

Terraform Lifecycle
- code, init, plan, validate, apply, destroy
- graph (For Visualizing Execution Plans) | terraform graph | dot -Tsvg ? graph.svg (Resource Graph)


Terraform Core and Plugins 
- Core : RPC (Remote Procedure calls) to communicate with Terraform Plugins
- Plugins: expose an implemtation for a specific service or provisioner

HashiCorp Cloud Platform (Include Terraform as Part of Products)



https://www.techbeatly.com/hashicorp-certified-terraform-associate-learning-exam-tips/


Terraform Best Practices: https://www.terraform-best-practices.com/


For Exam
https://www.youtube.com/watch?v=V4waklkBC38
