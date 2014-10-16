#!/bin/sh

COUNTRY="FI"
TIMEZONE="Europe/Helsinki"
TIMEHOST="time.euro.apple.com"

PREFS="/Library/Preferences"
USERPREFS="/System/Library/User Template/Non_localized/Library/Preferences"

if [ -s /Library/Custom/postinstall.conf ]; then
    # Set ADMINPASS in here:
    . /Library/Custom/postinstall.conf
fi

echo "Started at: $(date)"

#
# Set login window notice
#

defaults write "$PREFS/com.apple.loginwindow" LoginwindowText -string "POST-INSTALL SETUP IN PROGRESS"

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

defaults write "$PREFS/.GlobalPreferences" Country -string "$COUNTRY"
if ! fgrep -q "LANG=" /etc/profile; then
    printf '\nexport LANG=en_US.UTF-8\n' >> /etc/profile
fi

systemsetup -settimezone $TIMEZONE
systemsetup -setnetworktimeserver $TIMEHOST
systemsetup -setusingnetworktime on

#
# Set default preferences
#

echo "Set default preferences"

# Enable firewall
defaults write "$PREFS/com.apple.alf" globalstate -int 1
# Do not create .DS_Store files on network drives
defaults write "$PREFS/com.apple.desktopservices" DSDontWriteNetworkStores -bool true
# Disable guest user
defaults write "$PREFS/com.apple.loginwindow" GuestEnabled -bool false
defaults write "$PREFS/com.apple.AppleFileServer" guestAccess -bool false
defaults write "$PREFS/SystemConfiguration/com.apple.smb.server" AllowGuestAccess -bool false
# Display login window as user and password prompts
defaults write "$PREFS/com.apple.loginwindow" SHOWFULLNAME -bool true
# Disable time machine prompts for new disks
defaults write "$PREFS/com.apple.TimeMachine" DoNotOfferNewDisksForBackup -bool true
# Disable bluetooth by default
defaults write "$PREFS/com.apple.Bluetooth" ControllerPowerState -bool false

# Disable icloud setup auto launch
defaults write "$USERPREFS/com.apple.SetupAssistant" DidSeeCloudSetup -bool true
defaults write "$USERPREFS/com.apple.SetupAssistant" LastSeenCloudProductVersion -string "10.10"
# Disable icloud as default save destination
defaults write "$USERPREFS/.GlobalPreferences" NSDocumentSaveNewDocumentsToCloud -bool false
# Disable automatic termination
defaults write "$USERPREFS/.GlobalPreferences" NSDisableAutomaticTermination -bool true
# Disable smooth scrolling and window animations
defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticWindowAnimationsEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSScrollAnimationEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSWindowResizeTime -float 0.01
# Expand save and print dialogs by default
defaults write "$USERPREFS/.GlobalPreferences" NSNavPanelExpandedStateForSaveMode -bool true
defaults write "$USERPREFS/.GlobalPreferences" PMPrintingExpandedStateForPrint -bool true
# Show file extensions
defaults write "$USERPREFS/.GlobalPreferences" AppleShowAllExtensions -bool true
# Disable text autocorrect
defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticDashSubstitutionEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticSpellingCorrectionEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" WebAutomaticSpellingCorrectionEnabled -bool false
# Enable screensaver password
defaults write "$USERPREFS/com.apple.screensaver" askForPassword -int 1
defaults write "$USERPREFS/com.apple.screensaver" askForPasswordDelay -float 5
# Disable dock unhide delay
defaults write "$USERPREFS/com.apple.dock" autohide-delay -float 0
# Enable finder statusbar
defaults write "$USERPREFS/com.apple.finder" ShowStatusBar -bool true
# Disable finder animations
defaults write "$USERPREFS/com.apple.finder" DisableAllAnimations -bool true
# Disable finder warnings
defaults write "$USERPREFS/com.apple.finder" FXEnableExtensionChangeWarning -bool false
defaults write "$USERPREFS/com.apple.finder" WarnOnEmptyTrash -bool false
# Disable auto open files in safari
defaults write "$USERPREFS/com.apple.Safari" AutoOpenSafeDownloads -bool false
# Enable Develop menu by default
defaults write "$USERPREFS/com.apple.Safari" IncludeDevelopMenu -bool true

# Set power management defaults
pmset -a 3
# Hibernate after 12 hours of sleep
pmset -a standbydelay 43200
# Forget filevault key when hibernating
pmset -a destroyfvkeyonstandby 1

#
# Create local admin user
#

ADMINUID="501"
ADMINGID="20"
ADMINNAME="Administrator"
ADMINUSER="adm"
ADMINPIC="/Library/User Pictures/Nature/Zen.tif"

if ! id $ADMINUID >/dev/null 2>&1 && test -n "$ADMINPASS"; then
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
fi

#
# Install software updates
#

softwareupdate --install --all

#
# Clean up and reboot
#

echo "Finished at: $(date)"

defaults delete "$PREFS/com.apple.loginwindow" LoginwindowText
rm -f /Library/Custom/postinstall.conf
rm -f /Library/LaunchDaemons/local.postinstall.plist
reboot
