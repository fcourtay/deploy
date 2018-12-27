#Enable apt repos
cat << EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse
#deb http://archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF

#allow ssh from nginxcrocs
cat << EOF > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM7FsFc8MPecANfdb5RcuD1Gx0CHbOpdnqVBslcAi1B9cST+IsCIA/UM4ZaMPSqltPiuPyst598bCT3U3ak46u8XB2ky2cPLcf6t4cG++RdfyRI5XaXL51cIbLrbkK1SYGnB4LnCj5kWmOGBtsrD6ApoS3awEnxTOc572a7B7eYSa3W3bjvBLWhDZOYnLJljN/v1Y2HHwH2VTADtAImXQbko8wz3/luXh8m48w38Xf36UGxjcc6RsIgwftyq0OFZ/kiiPT2Z5oxupOJEY2vVn6mIBFBCavHbbmqNIpIJOi9k8x7Qfdfit4dBVoUPXTxzVjS4MasbIK6EhnG3+MqNbJ root@nginxcrocs
EOF

#Permit root login (bad)
sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

#update and install packages
sudo apt-get update && \
sudo apt-get install -y curl zsh htop links qemu-guest-agent && \
sudo apt-get -y upgrade 

#setup auto updates
cat << EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
sed -i 's|//	"${distro_id}:${distro_codename}-updates";|	"${distro_id}:${distro_codename}-updates"; |g' /etc/apt/apt.conf.d/50unattended-upgrades


#install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sed -i 's/ZSH_THEME=.*$/ZSH_THEME="gentoo"/g' "$HOME/.zshrc"
chsh -s /bin/zsh
source ~/.zshrc

