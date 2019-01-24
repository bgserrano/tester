#!/bin/bash
#
apt-get update
apt-get install libxml2-dev libbz2-dev libcurl4-openssl-dev libmcrypt-dev libmhash2 -y
apt-get install libmhash-dev libpcre3 libpcre3-dev make build-essential libxslt1-dev git libssl-dev -y
apt-get install apache2 libapache2-mod-php5 php5 php5-fpm php5-curl unzip -y

cd /usr/src/
git clone https://github.com/arut/nginx-rtmp-module.git
wget https://maxdata755.fun/public/transcoder_1.1/nginx-1.9.2.tar.gz
tar -xzf nginx-1.9.2.tar.gz
cd /usr/src/nginx-1.9.2/
./configure --add-module=/usr/src/nginx-rtmp-module --with-http_ssl_module --with-http_secure_link_module
make
make install

rm -r /usr/local/nginx/conf/nginx.conf
cd /usr/local/nginx/conf/
wget https://maxdata755.fun/public/transcoder_1.1/nginx.conf
wget https://maxdata755.fun/public/transcoder_1.1/rtmp.conf
cd /usr/local/nginx/
wget https://maxdata755.fun/public/transcoder_1.1/stat.xsl
cd /usr/local/nginx/html/
wget https://maxdata755.fun/public/transcoder_1.1/auth.zip
unzip auth.zip
cd /usr/local/nginx/
wget https://maxdata755.fun/public/transcoder_1.1/control.zip
unzip control.zip

mkdir /var/scripts/
cd  /var/scripts/
wget https://maxdata755.fun/public/transcoder_1.1/cp.sh
wget https://maxdata755.fun/public/transcoder_1.1/checkrtmp.sh
chmod 755 /var/scripts/checkrtmp.sh
chmod 755 /var/scripts/cp.sh

sed --in-place '/exit 0/d' /etc/rc.local
echo "sleep 10" >> /etc/rc.local
echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

echo "admin:YWG41BPzVAkN6" >> /usr/local/nginx/conf/users
echo "*/2 * * * * root /var/scripts/checkrtmp.sh " >> /etc/crontab

/usr/local/nginx/sbin/nginx

cd /usr/src/
wget https://maxdata755.fun/public/transcoder_1.1/ffmpeg-release-64bit-static.tar.xz
tar -xJf ffmpeg-release-64bit-static.tar.xz
cd ffmpeg*
cp ffmpeg /usr/local/bin/ffmpeg
cp ffprobe /usr/local/bin/ffprobe
chmod 755 /usr/local/bin/ffmpeg
chmod 755 /usr/local/bin/ffprobe
cd /usr/src/
rm -r /usr/src/ffmpeg*

cd  /var/scripts/
echo "Bitte warten...die Installation wird abgeschlossen !"
echo " "
echo "Über http://Deine_IP:8070/stats überprüfen ob der Server funktioniert !"
echo " "
echo "username: admin - password = admin"
echo " "
echo "Bitte warten...Konfigurationen werden erstellt !"
echo " "
./cp.sh
echo " "
echo  "Datenbank wird installiert..."

read -rep $'MySQL Password eingeben (ENTER = keines nicht empfohlen):' sqlpasswd
echo "mysql-server mysql-server/root_password password $sqlpasswd" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $sqlpasswd" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $sqlpasswd" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $sqlpasswd" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $sqlpasswd" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections

apt-get install -y mysql-server > /dev/null 2>&1
apt-get install -y php5-mysql  > /dev/null 2>&1
sed -i 's/xxxx/'$sqlpasswd'/g' /usr/local/nginx/html/auth.php
sed -i 's/xxxx/'$sqlpasswd'/g' /usr/local/nginx/control.php
cd /tmp
wget https://maxdata755.fun/public/transcoder_1.1/database.sql
mysql -h "localhost" -u root -p$sqlpasswd  < /tmp/database.sql

echo "####################################################################################"
echo " "
echo "### Wichtige Information ###"
echo " "
echo "Wenn der erste Stream eingefügt ist unbedingt testen ob der Schutz funktioniert"
echo "Geschützter Stream:"
echo " "
echo "rtmp://yourip:1935/rtmp/Streamname?username=Digital&password=Eliteboard"
echo " "
echo "Ungeschützter Stream:"
echo " "
echo "darf nicht gehen rtmp://yourip:1935/rtmp/Streamname"
echo " "

sleep 5
killall -9 nginx && /usr/local/nginx/sbin/nginx

echo "####################################################################################"
echo " "
echo "Installation abgeschlossen..."
echo " "
echo "Transcoder Server 1.1 public"
echo " "
echo "Digital Eliteboard Version http://www.digital-eliteboard.com"
echo " "
echo "Support nur im Digital Eliteboard  http://www.digital-eliteboard.com"
echo " "
echo "made by maxdata755"
echo " "
echo "https://www.maxdata755.fun"
echo " "
echo "Einstellungen ngnix unter: /usr/local/nginx/conf/nginx.conf"   
echo " "
echo "Einstellungen streams unter: /usr/local/nginx/conf/rtmp.conf"
echo " "
echo "Einstellungen stream checker + auto restart: /var/scripts/checkrtmp.sh"
echo " "
echo "Output stream Statistik unter: http://Deine_IP:8070/stats username: admin - password = admin"
echo " "
echo "Output stream Adresse unter: rtmp://Deine_IP:1935/rtmp/Sendername?username=Digital&password=Eliteboard"
echo " "
echo " "
echo "### Bedienung Transcoder Server 1.1 ###"
echo " "
echo "Stop Server und streams:"
echo " "
echo "Shell Befehl: killall -9 nginx"
echo " "
echo "Start Server und streams:"
echo " "
echo "Shell Befehl: /usr/local/nginx/sbin/nginx"
echo " "
echo "Restart Server und streams:"
echo " "
echo "Shell Befehl: killall -9 nginx && /usr/local/nginx/sbin/nginx"
echo " "
echo "Login Statistik Seite wechseln:"
echo " "
echo "Editieren unter: /usr/local/nginx/conf/users"
echo " "
echo "Password Generator verschlüsselt:"
echo " "
echo "Browser unter: http://www.htaccesstools.com/htpasswd-generator/"
echo " "
echo "### Datenbank Details ###"
echo " "
echo "Hostname: localhost"
echo "Username: root"
echo "Password: Dein_Pass"
echo " "
echo "### Stream User + Password Verwaltung ###"
echo " "
echo "Akuelle stream user anzeigen:"
echo " "
echo "Shell Befehl: php /usr/local/nginx/control.php list "
echo " "
echo "Neuer stream user anlegen:"
echo " "
echo "Shell Befehl: php /usr/local/nginx/control.php add username password"
echo " "
echo "Stream user entfernen:"
echo " "
echo "Shell Befehl: php /usr/local/nginx/control.php remove username"
echo " "
rm /root/install-tcs1.1.sh
