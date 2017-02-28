#!/bin/bash
pwd=`dirname $0`
dir=/var/www
dbname=wordpress
rootpass=rootpass
dbuser=dbuser
dbuserpass=dbuserpass


if [ ! -d "$dir" ]; then
	sudo mkdir -p $dir
fi

echo "mysql-server-5.5 mysql-server/root_password password "$rootpass"" | sudo debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password "$rootpass"" | sudo debconf-set-selections

sudo apt-get install -y \
	mysql-server-5.5 \
	nginx \
	php5-curl \
	php5-fpm \
	php5-gd \
	php5-mysql \
	wget \
	unzip
	
sudo replace "2M" "10M" -- /etc/php5/fpm/php.ini
sudo service php5-fpm restart

sudo mysql -e "CREATE DATABASE IF NOT EXISTS $dbname;"
echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbuserpass';" | mysql -u root -p$rootpass
echo "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';" | mysql -u root -p$rootpass
echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass

cd $dir
sudo wget http://wordpress.org/latest.zip
sudo unzip latest.zip > /dev/null

sudo rm -rf wp-*/

sudo mv wordpress/* .
sudo rm -rf index.html wordpress latest.zip

sudo chown -R www-data:www-data $dir
sudo chmod -R 775 $dir

u=$SUDO_USER
if [ -z $u ]; then
	u=$USER
fi

if !(groups $u | grep >/dev/null www-data); then
	sudo adduser $u www-data
fi


sudo cp $dir/wp-config-sample.php $dir/wp-config.php
sudo chmod 640 $dir/wp-config.php
sudo sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$dbuserpass/" $dir/wp-config.php




sites="/etc/nginx/sites-enabled"

sudo cat <<'EOF' >> $sites/wordpress
server {
	listen 80;
	server_name _;
	root /var/www;
	index index.php;
	location / {
		try_files $uri $uri/ /index.php?q=$uri&$args;
	}
	location /xmlrpc.php {
		deny all;
	}
	location ~ \.php$ {
		try_files $uri =404;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
	}
}
EOF



sudo replace "/var/www" $dir -- "$sites/wordpress"

if [ -e "$sites/default" ]; then
	sudo rm "$sites/default"
fi

sudo service mysql restart
sudo service nginx restart
