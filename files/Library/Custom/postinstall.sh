#!/bin/sh

COUNTRY="FI"
TIMEZONE="Europe/Helsinki"
TIMEHOST="time.euro.apple.com"

PREFS="/Library/Preferences"
USERHOME="/System/Library/User Template/Non_localized"
USERPREFS="$USERHOME/Library/Preferences"

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
defaults write "$PREFS/com.apple.alf" allowsignedenabled -int 0
# Do not create .DS_Store files on network drives
defaults write "$PREFS/com.apple.desktopservices" DSDontWriteNetworkStores -bool true
# Disable guest user
defaults write "$PREFS/com.apple.loginwindow" GuestEnabled -bool false
defaults write "$PREFS/com.apple.AppleFileServer" guestAccess -bool false
defaults write "$PREFS/SystemConfiguration/com.apple.smb.server" AllowGuestAccess -bool false
# Display login window as user and password prompts
defaults write "$PREFS/com.apple.loginwindow" SHOWFULLNAME -bool true
# Disable saving open applications on reboot
defaults write "$PREFS/com.apple.loginwindow" TALLogoutSavesState -bool false
# Disable time machine prompts for new disks
defaults write "$PREFS/com.apple.TimeMachine" DoNotOfferNewDisksForBackup -bool true
# Disable bluetooth by default
defaults write "$PREFS/com.apple.Bluetooth" ControllerPowerState -bool false

# Disable icloud setup auto launch
defaults write "$USERPREFS/com.apple.SetupAssistant" DidSeeCloudSetup -bool true
defaults write "$USERPREFS/com.apple.SetupAssistant" LastSeenBuddyBuildVersion -string "$(sw_vers -buildVersion)"
defaults write "$USERPREFS/com.apple.SetupAssistant" LastSeenCloudProductVersion -string "$(sw_vers -productVersion)"
# Disable press and hold feature for accented letters
defaults write "$USERPREFS/.GlobalPreferences" ApplePressAndHoldEnabled -bool false
# Disable autosave
defaults write "$USERPREFS/.GlobalPreferences" NSCloseAlwaysConfirmsChanges -bool true
# Disable icloud as default save destination
defaults write "$USERPREFS/.GlobalPreferences" NSDocumentSaveNewDocumentsToCloud -bool false
# Disable automatic termination
defaults write "$USERPREFS/.GlobalPreferences" NSDisableAutomaticTermination -bool true
# Disable saving windows on quit
defaults write "$USERPREFS/.GlobalPreferences" NSQuitAlwaysKeepsWindows -bool false
# Disable smooth scrolling and window animations
defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticWindowAnimationsEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSScrollAnimationEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSUseAnimatedFocusRing -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSWindowResizeTime -float 0.01
# Expand save and print dialogs by default
defaults write "$USERPREFS/.GlobalPreferences" NSNavPanelExpandedStateForSaveMode -bool true
defaults write "$USERPREFS/.GlobalPreferences" NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write "$USERPREFS/.GlobalPreferences" PMPrintingExpandedStateForPrint -bool true
defaults write "$USERPREFS/.GlobalPreferences" PMPrintingExpandedStateForPrint2 -bool true
# Show file extensions
defaults write "$USERPREFS/.GlobalPreferences" AppleShowAllExtensions -bool true
# Disable text autocorrect
defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticDashSubstitutionEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticSpellingCorrectionEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" WebAutomaticDashSubstitutionEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" WebAutomaticSpellingCorrectionEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" WebAutomaticTextReplacementEnabled -bool false
defaults write "$USERPREFS/.GlobalPreferences" WebContinuousSpellCheckingEnabled -bool false
# Enable screensaver password and set start time to 5 minutes
defaults write "$USERPREFS/com.apple.screensaver" askForPassword -int 1
defaults write "$USERPREFS/com.apple.screensaver" askForPasswordDelay -float 5
defaults -currentHost write "$USERPREFS/ByHost/com.apple.screensaver" idleTime -int 300
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
# Always show full URL
defaults write "$USERPREFS/com.apple.Safari" ShowFullURLInSmartSearchField -bool true
# Disable Spotlight suggestions
defaults write "$USERPREFS/com.apple.Safari" UniversalSearchEnabled -bool false
defaults write "$USERPREFS/com.apple.lookup" lookupEnabled -dict suggestionsEnabled 0
# Disable OCSP
defaults write "$USERPREFS/com.apple.security.revocation" OCSPStyle -string "None"
# Disable bash sessions
touch "$USERHOME/.bash_sessions_disable"

# Set power management defaults
pmset -a 3
# Sleep only on battery power
pmset -a sleep 0
pmset -b sleep 30
# Hibernate after 12 hours of sleep
pmset -a standbydelay 43200
# Forget filevault key when hibernating
pmset -a destroyfvkeyonstandby 1
# Disable autopoweroff
pmset -a autopoweroff 0
# Disable powernap
pmset -a darkwakes 0
# Disable wake on lan
pmset -a womp 0

# Enable sudo tty_tickets
mkdir -p /etc/sudoers.d
echo "Defaults tty_tickets" >/etc/sudoers.d/tty_tickets

#
# Create local admin user
#

ADMINUID="501"
ADMINNAME="Administrator"
ADMINUSER="adm"

if ! id $ADMINUID >/dev/null 2>&1 && test -n "$ADMINPASS"; then
    echo "Create user: $ADMINUSER"

    sysadminctl -addUser "$ADMINUSER" -fullName "$ADMINNAME" \
        -UID "$ADMINUID" -password "$ADMINPASS" -admin
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
