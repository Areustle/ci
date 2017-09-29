#!/bin/bash
yum update -y
yum install -y centos-release-scl-rh
yum install -y docker rh-git29-git python27 java-1.8.0-openjdk

curl http://yum.slac.stanford.edu/go-chef | /bin/sh

echo -e "#!/bin/bash\nsource scl_source enable python27 rh-git29" > /etc/profile.d/python27-git29.sh
yum clean all

groupadd docker
systemctl enable docker
systemctl start docker
usermod -aG docker bvan
usermod -aG docker glast
