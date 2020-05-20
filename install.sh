#!/bin/bash

#bill.000.vaughn@gmail.com
#04MAY2020

#Updated 15MAY2019

echo $HOME >> ./HOMEDIR.t

####
#HardCode this script to run as user root
#Needed to change the hostname
####
[ `whoami` = root ] || exec su -c $0 $1 root

####
#----------------
#  Glob Variables
#----------------
####
DOMAIN="static.foo.com"
banner="========================================================================="

#-----------------------------------------------------------------------------------#
#   								Functions										#
#-----------------------------------------------------------------------------------#

####
#Check permissions
####
checkPermission(){
if [ "$(id -u)" -ne 0 ]; then
        header
		echo "This script must be run using sudo!"
        exit 0
fi
   }
####

####
#Help Menu
#AdditionalINfo For Help
install_help(){
header "	Installation_Automation_Mutltiple_Sensors Help Info	"
echo " 
--This script must be ran with elevated privilages and requires two arguments
	
	arg[0] = The name of script ./{this_script_name}
	
	arg[1] = The Node -or -h -or --help (this menu)  {Node} || {-h} || {--help}

example1 sudo ./install TCN8675309
	-- Start the installation for Node TCN8675309
	-- Node.conf contains the paramaters to be used for setup
	
example2 sudo ./install -h
	-- Bring up this menu	"
additional_info;	
}
additional_info(){
echo "
-- 	The installation script uses the accompanying Node.conf to set the objects and paramaters
	for a precreated sosetup.conf.  Node.conf contains node specific information, such as IP, NETMASK, ect.
	
--	The sosetup.conf was created utilizing the -w option.  For more information about the the sosetup.conf 
	(ie answer file) See the Seco Wiki
	Also, support Security Onions non-profit and buy the hard printed manual on Amazon.  Any plug to support
	the great work and free products they provide is shamelessly done with no affiliation, their knowledge
	or approval.

----------------------------------------------------------------------------------
	
		
	-- use Node.conf to view, create, update, 
		or delete node records and/or paramaters
		
	-- Highly recommend security onions onsite training.
		5 Star quality training, insturctors, technicians,
		and professionals!
				
"
    }
####

####
#banner call
####
header(){
echo
printf '%s\n' "$banner" "$*" "$banner"
   }
####

####
#SO Syslog Apache Mysql Service cmd w/ $arg (ServicesCntl start/stop/restart)
####
ServicesCntl(){
so-$1
service syslog-ng $1
service apache2 $1
service mysql $1	
/etc/init.d/network-manager $1 
	}
####

###
#Stop Network Manager
###
NetworkCntl(){
/etc/init.d/network-manager $1

FILE=/etc/init/network-manager.conf
if [ -f "$FILE" ]; then
 mv /etc/init/network-manager.conf /etc/init/network-manager.conf.DISABLED  
fi
######Questions Do we need to keep it permently disabled? Does it affect the resolv.conf, manually need to update?
    }
####

####
#LVM
#part,assign to vg, and extend 2nd HD
####
LVM_Op(){
ServicesCntl stop
sed 's/^4/#/' /etc/cron.d/nsm-watchdog
pvcreate /dev/sdb
vgextend securityonion-vg /dev/sdb
lvm lvextend -l +100%FREE /dev/securityonion-vg/root
sed 's/^#/4/' /etc/cron.d/nsm-watchdog
   }
####

####
#Node Select
#####
NodeSelect(){
if egrep -i "$NODE" Node.conf > t.t
then
	awk -F: '{print $1 $2 $3 $4 $5 $6 $7}'  t.t > Node.t; echo "NODE CONFIG"; cat t.t; sleep 1
else
	echo "A record for $NODE was not found.";
	header "		INFO";
	additional_info;
	exit 0
fi
    }
####

####
#Create and Validate Pass
# currently leaving unused...the SO scripts are to easy, no use storing now
#####
CreatePass(){
read -s -p "Create the at least 6 character Password for Sguil: 
" mps
read -s -p "Enter Password One More Again: 
" mps2
ValidatePass
	}	
ValidatePass(){
if [ "$mps" == "$mps2" ] ;then
echo "Successfully Created"
	else
		echo "Does Not Match. Try Again!"                                
		CreatePass
fi
	}
####

####
#IPPrefix from Subnet Mask
####
IPprefix_by_netmask () { 
   c=0 x=0$( printf '%o' ${1//./ } )
   while [ $x -gt 0 ]; do
       let c+=$((x%2)) 'x>>=1'
   done
  Cdr=$(echo /$c ;)
  echo $Cdr
	}
####
  


####
 
####
#Create Variables Validation or poss. alt. coa ...mtf
#not currently used
####
createTempConfigVars(){
echo "UNIT=$UNIT">>config.t
echo "NODE=$NODE">>config.t
echo "IP=$IP">>config.t
echo "NETMASK=$NETMASK">>config.t
echo "GW=$GW">>config.t
echo "DNS=$DNSVR">>config.t
echo "USERNAME=$USERNAME">>config.t
echo "NEWSVRNAME=$NEWSVRNAME">> config.t
echo "CIDR=$Cdr">>config.t
echo "HOMENET=$HOMENET">>config.t
echo "HOME=$HOMEDIR">>config.t
echo "SNIFF=$SNIFF">>config.t
echo "MGMT=$MGMT">>config.t
echo "DOMAIN=$DOMAIN">>config.t
echo "ALL_IF=$ALL_IF">>config.t
echo "NUM_IF=$NUM_IF">>config.t
    }
####

###
#Stage the Templates
###
stageTemplate(){
cat $1 > ./tempConfig.t
sed -i "s/_NODE_/$NODE/g" ./tempConfig.t
sed -i "s/_MGMT_/$MGMT/g" ./tempConfig.t 
sed -i "s/_IPADDr_/$IPADDr/g" ./tempConfig.t
sed -i "s/_SNIFF_/$SNIFF/g" ./tempConfig.t
sed -i "s/_GW_/$GW/g" ./tempConfig.t
sed -i "s/_NETID_/$NETID/g" ./tempConfig.t
sed -i "s/_NETMASK_/$NETMASK/g" ./tempConfig.t
sed -i "s/_HOMEDIR_/$HOMEDIR/g" ./tempConfig.t
sed -i "s/_HOMENET_/$HOMENET/g" ./tempConfig.t
sed -i "s/_ALL_IF_/$ALL_IF/g" ./tempConfig.t
sed -i "s/_NUM_IF_/$NUM_IF/g" ./tempConfig.t
sed -i "s/_USERNAME_/$USERNAME/g" ./tempConfig.t
sed -i "s/_DOMAIN_/$DOMAIN/g" ./tempConfig.t
sed -i "s/_DNSSVR_/$DNSSVR/g" ./tempConfig.t
sed -i "s/_PASS_/$PASS/g" ./tempConfig.t

  }
####  

####
#Create FW Rules
####
UFW_FWConfig(){
# Firewall rules for Splunk forwarding 8089 9996 8000
# Below are examples 
# Splunk for splunk w/ links to all master sensors in dashboard
# optionally the smarter option is to run sudo so-allow after script completes 
# for the common wazuh, syslog, ect.
# May want to add to the Node.conf or some other thing later
# Also Considering Tuning steps for my specific enviroment as 
# part of the SIEM setup...likely value added for 1 conf file
# to help my specific org deployments
# Nice to haves at this current moment
####
	#${SOCSubnet}

	
	ufw allow from 111.111.111.111/32 to any port 22
	ufw allow from 111.111.111.111/32 to any port 80
	ufw allow from 111.111.111.111/32 to any port 443
	ufw allow from 111.111.111.111/32 to any port 7743
	ufw allow from 111.111.111.111/32 to any port 8000
	ufw allow from 111.111.111.111/32 to any port 8089
	ufw allow from 111.111.111.111/32 to any port 9996

	ufw allow from 111.111.111.111/32 to any port 22
	ufw allow from 111.111.111.111/32 to any port 80
	ufw allow from 111.111.111.111/32 to any port 443
	ufw allow from 111.111.111.111/32 to any port 7743
    }
####

####################################################################################
#							Setup / Install Server Logic						   #
####################################################################################

####
# Check Arguments
# Check Permission
# Display Help if requested or $1 is not present
####
if [ "$#" -eq 0  ]; then
		install_help
		exit 0
	elif [[ $1 == "-help"]||[$1 == "-h" ]]; then
				install_help
				exit 0
else
NODE=$(echo $1)
checkPermission

####
# Stop Services
# Setup Hard Drive
# Cut Node Info from TCN File to create Var
# Run Answer File
# Create FW rules
# Change hostname
# Reboot
#########
header "		Stopping Services"
ServicesCntl stop
header "		Logical Volume Manipulation"
LVM_Op

header " Creating Node Variables based on the node defined when launching install script"
NodeSelect
header " SecOnion installation for $NODE will be attempted using configuration settings in the TCN.conf file..."

#Starting Services
###
#header "		Starting Services"
#ServicesCntl start

header " Stopping Services"
#Stop Services
ServicesCntl stop
header " Stopping Network Manager"
#Stop Network
NetworkCntl stop

HOMEDIR=`head -n 1 HOMEDIR.t`
INTERFACES=`awk '/:/ {print $1}' /proc/net/dev | tr -d ':' | grep -v "^lo$" | grep -v "^docker" | grep -v "^br-" | grep -v "^veth" | sort`
ALL_IF=`echo $INTERFACES`
NUM_IF=`echo $INTERFACES | wc -w`
SNIFF=`echo $INTERFACES | cut -d " " -f2`
MGMT=`echo $INTERFACES | cut -d " " -f1`
UNIT=`cut -d "," -f1 ./Node.t`
NODE=`cut -d "," -f2 ./Node.t`
IPADDr=`cut -d "," -f3 ./Node.t`
NETMASK=`cut -d "," -f4 ./Node.t`
GW=`cut -d "," -f5 ./Node.t`
DNSSVR=`cut -d "," -f6 ./Node.t`
USERNAME=`head -n 1 HOMEDIR.t | cut -d"/" -f3`
#CreatePass
#PASS=`echo $mps`
NEWSVRNAME=`echo $UNIT"-"$NODE"-SO"`
CIDR=$(IPprefix_by_netmask "$NETMASK";)

IFS=. read -r i1 i2 i3 i4 <<< "$IP"
IFS=. read -r m1 m2 m3 m4 <<< "$NETMASK"
NETID="$((i1 & m1)).$((i2 & m2)).$((i3 & m3)).$((i4 & m4))"

#Replace The /etc/network/interfaces file with configuration
stageTemplate ./interfaces-template 

cat ./tempConfig.t
mv ./tempConfig.t /root/setupback/interfaces-generated.conf
mv -f ./tempConfig.t /etc/network/interfaces

NetworkCntl start
nohup sleep 2 &

#FW Stuff
header " Creating Firewall rules."
UFW_FWConfig

stageTemplate sosetuptemplate.conf 
mv tempConfig.t "$HOMEDIR"/sosetup.conf


sosetup -f "$HOMEDIR"/sosetup.conf
nohup sleep 5 &

mv "$HOMEDIR"/sosetup.conf /root/setupback/SO-AUTOMATED.conf
nohub sleep 5 &



chmod 760 /etc/hosts
chmod 760 /etc/hostname
echo $NEWSVRNAME > /etc/hostname
sed -i '2d /etc/hosts'
sed -i "2i 127.0.1.1   ${NEWSVRNAME}" /etc/hosts
rm -rf ./*.t
sed -i "s/$PASS/---PASSWORD REMOVED----/g" /root/setupback/*

header " Create User Password for Squert / Kibana / Squil "

so-user-add

nohub sleep 1 &
#####


reboot

exit
fi
exit 0;

