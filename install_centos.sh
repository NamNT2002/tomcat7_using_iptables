#!/bin/bash
#shell Multiwork Tomcat Using Apache
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi
clear
intpacket=''
sed -i 's/SELINUX=enforing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
echo "Please Wait.... Check and install packet"
#Install HTTPD
	if [ -z $(rpm -qa httpd) ]; then
		intpacket="$intpacket httpd"
	fi

	if [ -z $(rpm -qa java-1.7.0-openjdk) ]; then
		intpacket="$intpacket java-1.7.0-openjdk"
	fi
	if [ -z $(rpm -qa lsof) ]; then
		intpacket="$intpacket lsof"
	fi
	if [ -z $(rpm -qa wget) ]; then
		intpacket="$intpacket wget"
	fi
	if [ -z $(rpm -qa zip) ]; then
		intpacket="$intpacket zip"
	fi
	if [ -z $(rpm -qa unzip) ]; then
		intpacket="$intpacket unzip"
	fi
	if [ "$intpacket" != "" ]; then
		yum -y install $intpacket > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo "error install! please try again."
			exit 1
		else
			echo "Install packet success full!"
			echo "Packet install: $intpacket"
		fi
		
	fi

 mkdir -p /usr/local/share/intpacket
 wget --directory-prefix=/usr/local/share/intpacket -q https://raw.githubusercontent.com/NamNT2002/tomcat7_using_iptables/68cc554a5284de717cc3c053b16bf10234a078de/apache-tomcat-7.0.59.tar.gz
 tar -xf /usr/local/share/intpacket/apache-tomcat-7.0.59.tar.gz -C /var/www/html/
 mv /var/www/html/apache-tomcat-7.0.59 /var/www/html/tomcat7
 useradd -d /var/www/html/tomcat7 tomcat
 passuser=`</dev/urandom tr -dc A-Za-z0-9'!@#$%^&*()' | head -c12`
 echo $passuser | passwd tomcat --stdin
 chown -R tomcat. /var/www/html/tomcat7
cat > /etc/init.d/tomcat7 << hspservice
#!/bin/bash

# Apache Tomcat7: Start/Stop Chuong Trinh
#
# chkconfig: - 90 10


. /etc/init.d/functions
. /etc/sysconfig/network

CATALINA_HOME=/var/www/html/tomcat7
TOMCAT_USER=tomcat
LOCKFILE=/var/lock/subsys/tomcat

RETVAL=0
start(){
   echo "Khoi Dong Chuong Trinh: "
   su - \$TOMCAT_USER -c "\$CATALINA_HOME/bin/startup.sh"
   RETVAL=\$?
   echo
   [ \$RETVAL -eq 0 ] && touch \$LOCKFILE
   return \$RETVAL
}

stop(){
   echo "Ngat Chuong Trinh: "
   \$CATALINA_HOME/bin/shutdown.sh
   RETVAL=\$?
   echo
   [ \$RETVAL -eq 0 ] && rm -f \$LOCKFILE
   return \$RETVAL
}

case "\$1" in
   start)
      start
      ;;
   stop)
      stop
      ;;
   restart)
      stop
      start
      ;;
   status)
      status tomcat
      ;;
   *)
      echo \$"Usage: \$0 {start|stop|restart|status}"
      exit 1
      ;;
esac
exit \$?
hspservice

chmod +x /etc/init.d/tomcat7
chkconfig --add tomcat7
chkconfig tomcat7 on
/etc/init.d/tomcat7 start

	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	 
	# Set the nat/mangle/raw tables' chains to ACCEPT
	iptables -t nat -P PREROUTING ACCEPT
	iptables -t nat -P OUTPUT ACCEPT
	iptables -t nat -P POSTROUTING ACCEPT
	 
	iptables -t mangle -P PREROUTING ACCEPT
	iptables -t mangle -P INPUT ACCEPT
	iptables -t mangle -P FORWARD ACCEPT
	iptables -t mangle -P OUTPUT ACCEPT
	iptables -t mangle -P POSTROUTING ACCEPT
	 
	# Cleanup.
	#------------------------------------------------------------------------------
	 
	# Delete all
	iptables -F
	iptables -t nat -F
	iptables -t mangle -F
	 
	# Delete all
	iptables -X
	iptables -t nat -X
	iptables -t mangle -X
	 
	# Zero all packets and counters.
	iptables -Z
	iptables -t nat -Z
	iptables -t mangle -Z
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -A PREROUTING -p udp -m udp --dport 80 -j REDIRECT --to-ports 8080
iptables -A INPUT -p tcp -m tcp --dport 80 -j LOG 
iptables -A INPUT -p tcp -m tcp --dport 8080 -j LOG
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -A INPUT -p icmp -j ACCEPT 
iptables -A INPUT -i lo -j ACCEPT 
iptables -A INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp --dport 8080 -j ACCEPT
iptables -P INPUT DROP

/etc/init.d/iptables save
/etc/init.d/iptables restart
echo '***********************************'
echo 'Install Success Full'
ipaddr=`ifconfig $(route -n | grep UG | awk '{print $8}') | grep -w 'inet' | awk '{print $2}' | sed 's/addr://g'`
echo "http://$ipaddr"
echo "Hoac:"
echo "http://$ipaddr:8080"
echo '***********************************'
echo "User access tomcat: tomcat"
echo "Password user tomcat: $passuser"