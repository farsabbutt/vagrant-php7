class Build
  def Build.configure(config, settings)

    # Configure The Box
    config.vm.box = "ncaro/php7-debian8-apache-nginx-mysql"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.7.7"

    if settings['networking'][0]['public']
      config.vm.network "public_network", type: "dhcp"
    end

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Debian_64"]
      vb.customize ["modifyvm", :id, "--audio", "none", "--usb", "off", "--usbehci", "off"]
    end

    # Configure Port Forwarding To The Box
    config.vm.network "forwarded_port", guest: 80, host: 3000
    config.vm.network "forwarded_port", guest: 443, host: 3000 #44300
    config.vm.network "forwarded_port", guest: 3306, host: 33060
    # fix port collision with other vagrant vms running on default 2222
    config.vm.network :forwarded_port, guest: 22, host: 2227

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      print "###"
      print settings["ports"]
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"] ||= "tcp"
      end
    end

    # Register All Of The Configured Shared Folders
    if settings['folders'].kind_of?(Array)
      settings["folders"].each do |folder|
        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil
      end
    end
 
    # If a database directory exists in the same directory as your Vagrantfile,
    # a mapped directory inside the VM will be created that contains these files.
    # This directory is used to maintain default database scripts as well as backed
    # up mysql dumps (SQL files) that are to be imported automatically on vagrant up
    ###############################config.vm.synced_folder "database/", "/srv/database"
        # If the mysql_upgrade_info file from a previous persistent database mapping is detected,
    # we'll continue to map that directory as /var/lib/mysql inside the virtual machine. Once
    # this file is changed or removed, this mapping will no longer occur. A db_backup command
    # is now available inside the virtual machine to backup all databases for future use. This
    # command is automatically issued on halt, suspend, and destroy if the vagrant-triggers
    # plugin is installed.
    vagrant_dir = File.expand_path(File.dirname(__FILE__))
    if File.exists?(File.join(vagrant_dir,'database/data/mysql_upgrade_info')) then
        config.vm.synced_folder "database/data/", "/var/lib/mysql", :mount_options => [ "dmode=777", "fmode=777" ]
    end

    # Turn on PHP-FPM for nginx, or enable the right module for Apache
    #if settings["php"] == 7
      config.vm.provision "shell", inline: "sudo service php5-fpm stop && sudo service php7-fpm restart"
      config.vm.provision "shell", inline: "sudo a2dismod php5 && sudo a2enmod php7 sudo a2enmod ssl"
      config.vm.provision "shell", inline: "sudo ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf"
      #if settings["nginx"] ||= false
      #    config.vm.provision "shell", inline: "sudo service php5-fpm stop && sudo service php7-fpm restart"
      #else
      #    config.vm.provision "shell", inline: "sudo a2dismod php5 && sudo a2enmod php7"
    #else
      #if settings["nginx"] ||= false
      #    config.vm.provision "shell", inline: "sudo service php7-fpm stop && sudo service php5-fpm restart"
      #else
      #    config.vm.provision "shell", inline: "sudo a2dismod php7 && sudo a2enmod php5"
      #end
    #end

    # Turn on the proper server
    config.vm.provision "shell" do |s|
#	s.inline = "% echo 'Listen 3000' | sudo tee -a /etc/apache2/ports.conf"
	s.inline = "sudo service nginx stop && sudo apache2ctl start"
        #if settings["nginx"] ||= false
        #  s.inline = "sudo apachectl stop && sudo service nginx restart"
        #else
        #  s.inline = "sudo service nginx stop && sudo apachectl restart"
        #end
    end
 
    # Always start MySQL on boot, even when not running the full provisioner
    config.vm.provision :shell, inline: "sudo service mysql restart", run: "always"
    config.vm.provision :shell, inline: "sudo service nginx stop", run: "always"
    config.vm.provision :shell, inline: "sudo apache2ctl restart", run: "always"
    
    # Install composer
    #config.vm.provision "shell", inline: "curl -Ss https://getcomposer.org/installer | php > /dev/null && sudo mv composer.phar /usr/bin/composer"
    # Install dependencies
    #config.vm.provision "shell", inline: "cd /var/www/html/ && php composer.phar install"
    
    # Import mysql dbs via script 
#
# FIX MEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
#
    #config.vm.provision :shell, inline: "./srv/database/import-sql.sh", run: "always"


  end
end
