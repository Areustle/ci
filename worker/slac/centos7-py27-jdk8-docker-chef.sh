#!/bin/bash
SLAVE_VERSION=3.12
JENKINS_USER=glast
JNLP_LINK=https://srs.slac.stanford.edu

# Install git, python, java, docker
# yum update -y
yum install -y centos-release-scl-rh
yum install -y docker rh-git29-git python27 java-1.8.0-openjdk
echo -e "#!/bin/bash\nsource scl_source enable python27 rh-git29" > /etc/profile.d/python27-git29.sh

# Cloud init (needed for chef)
yum install -y cloud-init

# Setup Docker
groupadd docker
systemctl enable docker
systemctl start docker

# Setup Jenkins
curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${SLAVE_VERSION}/remoting-${SLAVE_VERSION}.jar
chmod 755 /usr/share/jenkins
chmod 644 /usr/share/jenkins/slave.jar
mkdir -p /home/jenkins/agent

cat >> /etc/systemd/system/jenkins.service <<EOF
[Unit]
Description=Jenkins Slave
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/bin/java -jar /usr/share/jenkins/slave.jar {args}
User=${JENKINS_USER}
Restart=always
EOF


# Install Chef, add groups
curl http://yum.slac.stanford.edu/go-chef | /bin/sh
usermod -aG docker bvan
usermod -aG docker glast

# Clean up
yum clean all
