#!/bin/bash
set -x -v
exec 1> /tmp/ks-pre.log 2>&1
 
HOSTNAME=$1
INTERFACE=$2
IPADDR=$3
HWADDR=$4
GATEWAY=$5
DNS=$6
 
B=`echo $IPADDR | awk -F '.' {'print $3'}`
NETWORK=192.168.$B.0
NETMASK=255.255.255.0
 
#################
### firstboot ###
#################
 
# grab firstboot script
cd /root/
wget http://192.168.0.212/post/id_rsa.pub
mkdir /root/.ssh
cat id_rsa.pub >> .ssh/authorized_keys
chmod 600 .ssh/authorized_keys

cd /root/
wget 192.168.0.212/post/guangpan.tar.gz
tar -zxvf guangpan.tar.gz
wget 192.168.0.212/post/macandconf

HOSTNAME=$(cat /etc/hostname)
#NIC=$(cat /root/macandconf|grep $HOSTNAME|awk '{print $3}' )
#MAC=$(ip addr|grep -A 1 eth2:|grep link|awk '{print $2}')

for i in $(cat /root/macandconf |grep $HOSTNAME); do 
echo $i >>/root/conf;
done
 
#auto deployment
cp /etc/crontab /etc/crontab.bak
cat >> /etc/crontab <<EOF
*/1 * * * * root /etc/installopenstack
EOF
cat > /etc/installopenstack <<HEHE
#!/bin/bash
HOSTNAME=$(cat /etc/hostname)
NIC=$(cat /root/macandconf|grep $HOSTNAME|awk '{print $2}' )
IP=$(ip addr|grep -A 1 eth2:|grep link|awk '{print $4}')
cat >/etc/network/interface <<EO
auto $NIC
iface $NIC inet static
address $IP
netmask 255.255.0.0
EO
/etc/init.d/networking restart
rm /etc/crontab
mv /etc/crontab.bak /etc/crontab
if [[ -e /root/lockfile ]] ; then
exit 0
fi
mkdir /var/lib/openstack
cp /root/conf /var/lib/openstack/conf
echo "lock" >>/root/lockfile
echo "diaodiao" >>/root/runtime
bash /root/guangpan/runwithconf.sh
HEHE
chmod +x /etc/installopenstack

 
# install the firstboot service

update-rc.d firstboot defaults

 
echo "finished postinst"
