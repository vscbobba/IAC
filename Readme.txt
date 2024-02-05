launch workstation from your own template, it should inlcude terraform install init.

then clone the git repo, start terraform implementation.

It will launch Ec2 instances in public subnet, it is Bastion host
                                private subnet, it is Frontned(we server).

If you accept VPC peering request from AWS console, you can connect to Frontned server from work station. {its just a test}

Because of NAT gateway, you can conect to Bastion and Frontend servers(20.0.0.0/16) from your workstation (30.0.0.0/16)