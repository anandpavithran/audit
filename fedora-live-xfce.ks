# fedora-livecd-xfce.ks
#
# Description:
# - Fedora Live Spin with the light-weight XFCE Desktop Environment
#
# Maintainer(s):
# - Anand Pavithran       <apavithr@redhat.com>

%include fedora-live-base.ks
%include fedora-live-minimization.ks
%include fedora-xfce-common.ks

%post
# xfce configuration

# create /etc/sysconfig/desktop (needed for installation)
#Create a local webserver and tary to fetch the file
wget http://192.168.122.1/test/audit-now -O /usr/sbin/audit-now
chmod +x /usr/sbin/audit-now

cat > /etc/sysconfig/audit.desktop  << COD

[Desktop Entry]
Name[en_GB]=GLSAudit
Name=GLSAudit
GenericName[af]=GLSAudit
GenericName=GLSAudit
Comment[en_GB]=To do Audit
Comment=To Audit
Categories=System;Utility;X-Red-Hat-Base;X-Fedora;GNOME;GTK;
Exec=/usr/sbin/audit-now
Terminal=false
Type=Application
Icon=fedora-logo-icon
StartupNotify=true
NoDisplay=false
X-Desktop-File-Install-Version=0.24

COD

cat > /etc/sysconfig/desktop <<EOF
PREFERRED=/usr/bin/startxfce4
DISPLAYMANAGER=/usr/sbin/lightdm
EOF

cat >> /etc/rc.d/init.d/livesys << EOF

mkdir -p /root/.config/xfce4

cat > /root/.config/xfce4/helpers.rc << FOE
MailReader=sylpheed-claws
FileManager=Thunar
WebBrowser=firefox
FOE

# disable screensaver locking (#674410)
cat >> /root/.xscreensaver << FOE
mode:           off
lock:           False
dpmsEnabled:    False
FOE

# deactivate xfconf-migration (#683161)
rm -f /etc/xdg/autostart/xfconf-migration-4.6.desktop || :

# deactivate xfce4-panel first-run dialog (#693569)
mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
cp /etc/xdg/xfce4/panel/default.xml /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml

# set up lightdm autologin
sed -i 's/^#autologin-user=.*/autologin-user=root/' /etc/lightdm/lightdm.conf
sed -i 's/^#autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
#sed -i 's/^#show-language-selector=.*/show-language-selector=true/' /etc/lightdm/lightdm-gtk-greeter.conf

# set Xfce as default session, otherwise login will fail
sed -i 's/^#user-session=.*/user-session=xfce/' /etc/lightdm/lightdm.conf

# Show harddisk install on the desktop
#sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
mkdir /root/Desktop
mkdir -p /root/Desktop/.local/share/applications
cp /etc/sysconfig/audit.desktop /root/Desktop/
cp /etc/sysconfig/audit.desktop /root/Desktop/.local/share/applications/
#cp /usr/share/applications/liveinst.desktop /root/Desktop
rm -f /usr/share/applications/liveinst.desktop

# no updater applet in live environment
rm -f /etc/xdg/autostart/org.mageia.dnfdragora-updater.desktop
rm -f /root/Desktop/liveinst.desktop

# and mark it as executable (new Xfce security feature)
#chmod +x /root/Desktop/liveinst.desktop
chmod +x /root/Desktop/audit.desktop

# this goes at the end after all other changes. 
chown -R root:root /root
restorecon -R /root
EOF

%end

