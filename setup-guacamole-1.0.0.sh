# Installs client and server for Guacamole 1.0.0
# Does not yet popululate config files


# Install Server
sudo yum update -y
sudo yum install cairo-devel libjpeg-devel libpng-devel uuid-devel freerdp-devel pango-devel libssh2-devel libssh-dev tomcat tomcat-admin-webapps tomcat-webapps
wget -O "guacamole-server-1.0.0.tar.gz" 'http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.0.0/source/guacamole-server-1.0.0.tar.gz'
tar zxf guacamole-server-1.0.0..tar.gz
cd guacamole-server-1.0.0
./configure
make
sudo make install
sudo ldconfig

# Install client
cd /var/lib/tomcat/webapps
sudo wget -O "guacamole.war" "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/1.0.0/binary/guacamole-1.0.0.war"
sudo mkdir /etc/guacamole
sudo mkdir /usr/share/tomcat/webapps/.guacamole
sudo vim /etc/guacamole/guacamole.properties

#
  guacd-hostname: localhost
  guacd-port:    4822
  user-mapping:    /etc/guacamole/user-mapping.xml
  auth-provider:    net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
  basic-user-mapping:    /etc/guacamole/user-mapping.xml
#

sudo ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat/webapps/.guacamole/
sudo vim /etc/guacamole/user-mapping.xml

#
  User properties go here
#
sudo chown 600 /etc/guacamole/user-mapping.xml
sudo chown tomcat:tomcat /etc/guacamole/user-mapping.xml

# Start Tomcat with systemd
sudo systemctl tomcat start
sudo systemctl enable tomcat

# Add the Guacd service to systemd 
sudo vim /etc/systemd/system/guac.service
#
    [Unit]
    Description=Guacamole Server
    Requires=network.target
    After=network.target

    [Service]
    User=tomcat
    Group=tomcat
    Type=simple
    ExecStart=/usr/local/sbin/guacd -f
    RestartSec=10
    Restart=on-abnormal

    [Install]
    WantedBy=multi-user.target

#

# Reload disk and start the service and enable to start on server reboot
systemctl daemon-reload
systemctl start guacd
systemctl enable guacd

# Allow firewall ingress port 8080
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Disable SELinux (might not be necessary)
sudo setenforce 0

# Fix console fonts
sudo yum install dejavu-sans-mono-fonts.noarch -y

