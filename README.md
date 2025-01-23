### coralogix_otel_on_ec2_tf



🔴This will create an EC2 machine with a security group rule open to all. Please ensure you customize this code according to your requirements🔴


Yes! Below is a Terraform module that deploys OpenTelemetry Collector on an AWS EC2 instance, with support for Coralogix integration. This module is reusable and can be used in multiple environments.





### 🚀 What This Terraform Module Does
```
✅ Creates an EC2 instance for OpenTelemetry
✅ Installs OpenTelemetry Collector (otelcol-contrib)
✅ Configures OpenTelemetry to send logs & metrics to Coralogix
✅ Ensures correct permissions (CAP_SYS_PTRACE & CAP_DAC_READ_SEARCH) for hostmetrics
✅ Uses a systemd service to auto-start OpenTelemetry
✅ Allows customization via module inputs (region, instance type, key pair, Coralogix API key, etc.)
```




### 1️⃣ Validate syntax : 
terraform validate

### 2️⃣ Initialize Terraform : 
terraform init

### 3️⃣ Apply the Terraform Configuration
terraform plan
terraform apply -auto-approve



### ✔ Summary
```
✅ Reusable Terraform Module for OpenTelemetry on EC2
✅ Supports sending logs & metrics to Coralogix
✅ Ensures correct systemd service & permissions
✅ Can be used across multiple environments
```


🚀 Now you can reuse this module in different projects! Let me know if you need modifications.
