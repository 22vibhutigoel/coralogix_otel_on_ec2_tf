module "otel_ec2" {
  source                     = "./modules/otel_ec2"
  ami_id                     = "ami-08c6ee7b1bc986bfb"  # Change according to your region ,Use this query  - aws ec2 describe-images --region us-east-1 --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images | sort_by(@, &CreationDate) | [-1].ImageId"
  instance_type              = "t2.micro"
  key_name                   = "vg" # Your key should be available under KeyPairs for selected region
  role_name                  = "otel-ec2-role"
  instance_name              = "otel-ec2-instance"
  coralogix_private_key      = "cXXXXXXXXXXXXXXXXXXXXXXXXXXI" # your coralogix api key
  coralogix_application_name = "ac2" 
  coralogix_subsystem_name   = "otel-ec2"
  coralogix_domain           = "coralogix.in" # Change if you are not using *.in domain 
}

