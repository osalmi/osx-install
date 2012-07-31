#!/bin/sh

COUNTRY="FI"
TIMEZONE="Europe/Helsinki"
TIMEHOST="time.euro.apple.com"
ADMINPASS="changeme"

#
# Set login window notice
#

defaults write "/Library/Preferences/com.apple.loginwindow" LoginwindowText -string "POST-INSTALL SETUP IN PROGRESS"

#
# Wait for network
#

while [ ! -f /var/run/resolv.conf ]; do sleep 10; done

#
# Set computer name
#

echo "Set ComputerName: $(hostname -s)"

scutil --set ComputerName $(hostname -s)
scutil --set LocalHostName $(hostname -s)

#
# Set locale and time settings
#

echo "Set Country: $COUNTRY"

defaults write "/Library/Preferences/.GlobalPreferences" Country -string "$COUNTRY"
systemsetup -settimezone $TIMEZONE
systemsetup -setnetworktimeserver $TIMEHOST
systemsetup -setusingnetworktime on

#
# Set default preferences
#

echo "Set default preferences"

# Enable firewall
defaults write "/Library/Preferences/com.apple.alf" globalstate -int 1
# Do not create .DS_Store files on network drives
defaults write "/Library/Preferences/com.apple.desktopservices" DSDontWriteNetworkStores true
# Disable guest user
defaults write "/Library/Preferences/com.apple.loginwindow" GuestEnabled -bool false
# Display login window as user and password prompts
defaults write "/Library/Preferences/com.apple.loginwindow" SHOWFULLNAME -bool true
# Disable time machine prompts for new disks
defaults write "/Library/Preferences/com.apple.TimeMachine" DoNotOfferNewDisksForBackup -bool true
# Disable icloud setup auto launch
defaults write "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.SetupAssistant" DidSeeCloudSetup -bool true
defaults write "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.SetupAssistant" LastSeenCloudProductVersion -string "10.8"
# Disable automatic termination
defaults write "/System/Library/User Template/Non_localized/Library/Preferences/.GlobalPreferences" NSDisableAutomaticTermination -bool true
# Disable smooth scrolling
defaults write "/System/Library/User Template/Non_localized/Library/Preferences/.GlobalPreferences" NSScrollAnimationEnabled -bool false
# Enable screensaver password
defaults write "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.screensaver" askForPassword -int 1
defaults write "/System/Library/User Template/Non_localized/Library/Preferences/com.apple.screensaver" askForPasswordDelay -float 5
# Set power management defaults
pmset -a 3

#
# Create local admin user
#

ADMINUID=501
ADMINGID=20
ADMINNAME=Administrator
ADMINUSER=adm
ADMINPIC="/Library/User Pictures/Nature/Zen.tif"

echo "Create user: $ADMINUSER"

dscl . -create /Users/$ADMINUSER
dscl . -create /Users/$ADMINUSER UniqueID $ADMINUID
dscl . -create /Users/$ADMINUSER PrimaryGroupID $ADMINGID
dscl . -create /Users/$ADMINUSER RealName "$ADMINNAME"
dscl . -create /Users/$ADMINUSER UserShell "/bin/bash"
dscl . -create /Users/$ADMINUSER NFSHomeDirectory "/Users/$ADMINUSER"
dscl . -create /Users/$ADMINUSER AuthenticationAuthority ";ShadowHash;"
dscl . -create /Users/$ADMINUSER Password "*"
dscl . -create /Users/$ADMINUSER sharedDir Public
dscl . -create /Users/$ADMINUSER _writers_hint $ADMINUSER
dscl . -create /Users/$ADMINUSER _writers_passwd $ADMINUSER
dscl . -create /Users/$ADMINUSER _writers_picture $ADMINUSER
dscl . -create /Users/$ADMINUSER _writers_realname $ADMINUSER
dscl . -create /Users/$ADMINUSER _writers_tim_password $ADMINUSER
dscl . -create /Users/$ADMINUSER Picture "$ADMINPIC"
dscl . -passwd /Users/$ADMINUSER $ADMINPASS

for group in admin _appserveradm _appserverusr _lpadmin; do
    dscl . -append /Groups/$group GroupMembership $ADMINUSER
done

createhomedir -c -u $ADMINUSER

#
# Install software updates
#

softwareupdate --install --all

#
# Clean up and reboot
#

echo "Finished at: $(date)"

defaults delete "/Library/Preferences/com.apple.loginwindow" LoginwindowText
rm -f /Library/LaunchDaemons/local.postinstall.plist
reboot
