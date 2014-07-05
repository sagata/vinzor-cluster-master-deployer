#!/bin/bash
echo -n "Enter IP : "
read IP
if [[ -e /root/ubuntu-12.04.2-server-amd64.iso ]] ; then 
echo ""
else
echo "\/root\/ubuntu-12.04.2-server-amd64.iso not found"
exit 0
fi
rm -rf /var/lib/apt/lists/lock
apt-get install -y --force-yes ubuntu-orchestra-server cobbler-web mc htop nload debmirror
mkdir /var/www/post
htdigest /etc/cobbler/users.digest "Cobbler" cobbler
mount -t auto -o loop /root/ubuntu-12.04.2-server-amd64.iso /mnt
cobbler import --name=Ubuntu-12.04.2 --path=/mnt
cobbler distro edit --name=Ubuntu-12.04.2-x86_64 --kernel=/var/www/cobbler/ks_mirror/Ubuntu-12.04.2/install/netboot/ubuntu-installer/amd64/linux --initrd=/var/www/cobbler/ks_mirror/Ubuntu-12.04.2/install/netboot/ubuntu-installer/amd64/initrd.gz --os-version=precise
cp guangpan.tar.gz /var/www/post
cp static.sh /var/www/post
rm /var/lib/cobbler/snippets/orchestra_proxy
cp orchestra_proxy /var/lib/cobbler/snippets/orchestra_proxy
sed -i "s/192.168.0.212/$IP/g" /var/lib/cobbler/snippets/orchestra_proxy
rm /etc/dnsmasq.conf
cp dnsmasq.conf /etc/dnsmasq.conf
cp vinzor /usr/bin/vinzor
cp ubuntu.preseed /var/lib/cobbler/kickstarts
sed -i "s/192.168.0.212/$IP/g" /var/www/post/static.sh
cobbler profile edit --name=Ubuntu-12.04.2-x86_64 --kopts="auto=true netcfg/choose_interface=auto" --kickstart=/var/lib/cobbler/kickstarts/ubuntu.preseed
ln -sv /var/www/cobbler/ks_mirror/Ubuntu-12.04.2/ /var/www/ubuntu
touch /var/www/ubuntu/dists/precise/restricted/binary-amd64/Packages
cat>input<<EOF

EOF
ssh-keygen -t rsa -P '' <input
cp /root/.ssh/id_rsa.pub /var/www/post
cat>/root/.ssh/config<<EOF
StrictHostKeyChecking no
EOF
cobbler sync
