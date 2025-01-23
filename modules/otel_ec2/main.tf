resource "aws_iam_role" "otel_role" {
  name = var.role_name
  assume_role_policy = <<EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOT
}

resource "aws_iam_policy" "otel_policy" {
  name        = "${var.role_name}-policy"
  description = "Permissions for OpenTelemetry on EC2"
  policy      = <<EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "ec2:DescribeInstances",
          "cloudwatch:PutMetricData"
        ],
        "Resource": "*"
      }
    ]
  }
  EOT
}

resource "aws_iam_role_policy_attachment" "otel_policy_attach" {
  role       = aws_iam_role.otel_role.name
  policy_arn = aws_iam_policy.otel_policy.arn
}

resource "aws_iam_instance_profile" "otel_profile" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.otel_role.name
}

resource "aws_security_group" "otel_sg" {
  name_prefix = "otel-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "otel_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.otel_profile.name
  vpc_security_group_ids = [aws_security_group.otel_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    sudo yum update -y
    curl -LO https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.93.0/otelcol-contrib_0.93.0_linux_amd64.rpm
    sudo yum install -y ./otelcol-contrib_0.93.0_linux_amd64.rpm
    sudo mkdir -p /etc/otelcol-contrib
    cat <<EOT | sudo tee /etc/otelcol-contrib/config.yaml
    receivers:
      filelog:
        include:
          - /var/log/syslog
          - /var/log/messages
        include_file_name: true
        include_file_path: true
        retry_on_failure:
          enabled: true
        start_at: beginning

      hostmetrics:
        collection_interval: 10s
        scrapers:
          cpu:
          filesystem:
          memory:
          network:
          process:

    processors:
      batch:
        send_batch_size: 1024
        timeout: "1s"
      resourcedetection:
        detectors: [system, env, ec2]
        timeout: 2s

    exporters:
      coralogix:
        domain: "${var.coralogix_domain}"
        private_key: "${var.coralogix_private_key}"
        application_name: "${var.coralogix_application_name}"
        subsystem_name: "${var.coralogix_subsystem_name}"
        timeout: 30s

    service:
      pipelines:
        logs:
          receivers: [filelog]
          processors: [resourcedetection, batch]
          exporters: [coralogix]
        metrics:
          receivers: [hostmetrics]
          processors: [resourcedetection, batch]
          exporters: [coralogix]
    EOT

    sudo setcap cap_sys_ptrace,cap_dac_read_search=eip /usr/bin/otelcol-contrib

    cat <<EOT | sudo tee /etc/systemd/system/otelcol.service
    [Unit]
    Description=OpenTelemetry Collector
    After=network.target

    [Service]
    ExecStart=/usr/bin/otelcol-contrib --config /etc/otelcol-contrib/config.yaml
    Restart=always
    User=root

    [Install]
    WantedBy=multi-user.target
    EOT

    sudo systemctl daemon-reload
    sudo systemctl enable --now otelcol
  EOF

  tags = {
    Name = var.instance_name
  }
}

