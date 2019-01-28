yum check-update -y
yum upgrade -y
yum install -y nano wget curl net-tools lsof bash-completion
yum clean all
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm -y
yum install p7zip
