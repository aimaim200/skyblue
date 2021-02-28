# skyblue

The Foler Contains two files and One Folder called Modules

The folder named Modules is a Terraform module 
# Allows you to group resources together and reuse this group later, possibly many times. in shot create logical abstraction on the top of some resource set.

# Main.tf is the file acts like an entry file it describes the AWS regions and the secret and access keys.

# The ec2 file contains details about the EC2 instance we desire to develop.  



Solution:

1.	EC2 instance have been setup using Terraform. We have used the latest Amazon linux AMI 
         “ami-00d44b7a06cf6701e”.       

2.	Standard user with sudo access: 
	Below steps will grant admin user full sudo privileges:
	 -   adduser admin
	 -   echo 'admin ALL=(ALL) NOPASSWD:  ALL' >> /etc/sudoers
	 -   passwd admin   admin

	 Disable root login:
	  -   vi /etc/ssh/sshd_config
	  -   Change #PermitRootLogin yes   PermitRootLogin no
	  -   /etc/init.d/sshd restart

3.	Script to monitor disk usage:
	 -    su admin
	 -     cd /home/admin/
	 -    vi disk_usage_monitor.sh

	#!/bin/bash
         -   echo -e "`date` \t  `df -h | egrep '^/dev/xvda1' | awk '{ print "Free space on "$6 " is " $4}'`" >> /var/log/freespace 
         -   chmod 744 disk_usage_monitor.sh
         -   sudo ./disk_usage_monitor.sh

4.	Schedule the script to run every 5 min:
        -    crontab -e
             */5 * * * * sudo  /home/admin/disk_usage_monitor.sh
	-    sudo service crond restart

5.	Logrotation every 1 hour:
         -   sudo vi /etc/logrotate.d/freespace
	/var/log/freespace {
	      missingok
	      notifempty
	      compress
	      hourly
	      rotate 10
	      create 0600 root root
	   }
	 -	sudo cp /etc/cron.daily/logrotate /etc/cron.hourly/
	 -	sudo vi /etc/cron.hourly/logrotate

	 #!/bin/sh

	 /usr/sbin/logrotate -s /var/lib/logrotate/logrotate.status /etc/logrotate.d/freespace
	  EXITVALUE=$?
		if [ $EXITVALUE != 0 ]; then
		    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
		fi
		exit 0
	   less /var/log/freespace

6.	Configure an external repo and install netdata:
	   -	sudo amazon-linux-extras install epel
	   -	cd /home/admin/
	   -	bash <(curl -Ss https://my-netdata.io/kickstart.sh)
	   -	Test if netdata is working :
	   curl http://localhost:19999/api/v1/info

7.	deploy docker and run nginx as a container:
	   -	sudo yum install -y docker
	   -	sudo service docker start
	   -	cd /home/admin
	   -	vi index.html

	    <!doctype html>
	    <html lang="en">
	    <head>
	      <meta charset="utf-8">
	      <title>Docker Nginx</title>
	    </head>
	    <body>
	      <h2>Hello, Sky</h2>
	    </body>
	    </html>

             -	vi dockerfile

	FROM nginx:latest
	COPY ./index.html /usr/share/nginx/html/index.html
	   -	sudo docker build -t webserver .
	   -	sudo docker run -it --rm -d -p 80:80 --name web webserver

	Start Docker and nginx at boot time:
	    -	sudo vi /etc/rc.local
	    -	append the below lines:
	    sudo service docker start
	    sudo docker run -it --rm -d -p 80:80 --name web webserver
	    -	sudo chmod +x /etc/rc.d/rc.local

NOTE: The Public AMI Macine is: Nginx_ec2.
