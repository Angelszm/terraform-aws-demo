#! /bin/bash

# Install and start nginx
sudo amazon-linux-extras install -y nginx1
sudo service nginx start

# Copy website assets from S3
aws s3 cp s3://${s3_bucket_name}/website/index.html /home/ec2-user/index.html
aws s3 cp s3://${s3_bucket_name}/website/DevOps.png /home/ec2-user/DevOps.png
aws s3 cp s3://${s3_bucket_name}/website/style.css /home/ec2-user/style.css


# Replace default website with downloaded assets
sudo rm /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
sudo cp /home/ec2-user/DevOps.png /usr/share/nginx/html/DevOps.png
sudo cp /home/ec2-user/style.css /usr/share/nginx/html/style.css