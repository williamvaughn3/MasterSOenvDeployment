# Template-multi-nodeSecOnionAutomatedDeployment
  
  Create template for deployment of a Multiple Security Onion Master Sensor enviorment using sosetup -w generated config file and predefined configuration values.

  Functionality:
  
  Designed to use a ovf file that is already prepped with the install from cd.  
  Automates LVM harddive expansion into the security onion root vg, configures network, and launches sosetup with using multiple master sensors defined in a Node.conf file
  
  Expansion for adding specific enviromental tuning would be a good thing to add at a later date.  
  
  For our personal eviroment, we will be just placing the files in the folder and
  will append the mv command after sosetup and prior to reboot.  For questions on tuning see the Security Onion WIKI, or buy their book.

		
  Explanation:
  
  Primary purpose is to ensure configuration integrity using automated  deployment via install.sh 
  script for Standalone Master Sensors at remote sites.
  
  Use Case is centered on resource restrictions. Bandwidth or latency restrictions 
  at remote sites may prohibit a Master/Node Sensor architecture. 
  Multiple Sensors remotely deployed depend on integrity of configuration. 
  Architecture technicians at remote sites have varying skillsets, and may
  be unfamiliar with Linux, Virtual requirements, ect.   For these limited situations, a core
  Network Defense team may manage multiple branch sensors, and provide
  an single OVF with this script for deploying enmass. 
  
  Our enviroment will be utilizing a SEIM recieving very specific logs via SYSLOG / Forwarders, 
  while still maintaining full PKT Capture at the remote branches. Resources permitting, this deplyoment 
  method may be automated much more efficiently utilizing Puppet, Chef, SaltStack, Ansible, ect.

  This is for setup only.  Tuneing bpf.conf, creating users, and all post installation tasks, tuning, 
  and whatnot still needs to happen. 
  
  Node.conf contains node specific information required for setup, 
  such as IP, NETMASK, ect.
  The installation script uses the Node.conf to define the variables to be used in creation of the secosetup.conf file.
  
  Original sosetup.conf file generated with SecOnion organic sosetup -w functionality.  
  
  Security Onion or employees of Security Onion have not endorsed, reviewed, or approved any work or comments.
  
  ######################################################################
  #  
  #  !!!!! Still will need updated for actual cores used  !!!!! 
  #  !!!!!      on sensors prior to deploying ovf         !!!!!
  # 
  #  This can be changed before or after setup.  Before ensure the VM has the resources, 
  #  and change the value in the sosetuptemplate file.
  # 
  #  Otherwise, see teh Security Onion Documentation for updating after deployment.
  #   
  #		-VM requirments after creation:
  #
  #		     o LVM enabled during CD install
  #		     o Add another harddrive 
  #		     o Ensure two NICs installed 
  #
  #######################################################################
  
  ##########
  # Things #
  ##########
  
  Need to still include the so-allow in the script prior to restart.
  A function to prompt for password exists, but is unused.
  Still need to change the Domain variable to be read from node.conf
  instead of the static variable at the top of the install.sh file.
  
  
  install_help(){

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

-- 	The installation script uses the accompanying Node.conf to define the objects and paramaters
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
 