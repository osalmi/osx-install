#!/bin/bash

COUNTRY="FI"
TIMEZONE="Europe/Helsinki"
TIMEHOST="time.euro.apple.com"

if [[ "$(whoami)" = "root" ]]; then
    USERHOME="/System/Library/User Template/Non_localized"
else
    USERHOME="$HOME"
fi

PREFS="/Library/Preferences"
USERPREFS="$USERHOME/Library/Preferences"

set_system_defaults() {
    # Enable firewall
    defaults write "$PREFS/com.apple.alf" globalstate -int 1
    defaults write "$PREFS/com.apple.alf" allowsignedenabled -int 0
    # Do not create .DS_Store files on network or USB drives
    defaults write "$PREFS/com.apple.desktopservices" DSDontWriteNetworkStores -bool true
    defaults write "$PREFS/com.apple.desktopservices" DSDontWriteUSBStores -bool true
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
    # Disable multicast DNS advertisements
    defaults write "$PREFS/com.apple.mDNSResponder" NoMulticastAdvertisements -bool true
    # Disable captive portal network probes
    defaults write "$PREFS/SystemConfiguration/com.apple.captive.control" Active -bool false

    # Sleep only on battery power
    pmset -a sleep 0
    pmset -b sleep 30
    # Display sleep timeouts
    pmset -a displaysleep 20
    pmset -b displaysleep 10
    # Hibernate after 12 hours of sleep
    pmset -a standbydelay 43200
    # Forget filevault key when hibernating
    pmset -a destroyfvkeyonstandby 1
    # Disable autopoweroff
    pmset -a autopoweroff 0
    # Disable powernap
    pmset -a darkwakes 0
    # Disable display dimming
    pmset -a lessbright 0
    # Disable wake on lan
    pmset -a womp 0

    # Enable sudo tty_tickets
    ( umask 027
      mkdir -p /etc/sudoers.d
      echo "Defaults tty_tickets" > /etc/sudoers.d/tty_tickets )

}

set_user_defaults() {
    # Disable icloud setup auto launch
    defaults write "$USERPREFS/com.apple.SetupAssistant" DidSeeCloudSetup -bool true
    defaults write "$USERPREFS/com.apple.SetupAssistant" DidSeeSyncSetup -bool true
    defaults write "$USERPREFS/com.apple.SetupAssistant" DidSeeSyncSetup2 -bool true
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
    defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticCapitalizationEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticDashSubstitutionEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticPeriodSubstitutionEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" NSAutomaticSpellingCorrectionEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" WebAutomaticDashSubstitutionEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" WebAutomaticQuoteSubstitutionEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" WebAutomaticSpellingCorrectionEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" WebAutomaticTextReplacementEnabled -bool false
    defaults write "$USERPREFS/.GlobalPreferences" WebContinuousSpellCheckingEnabled -bool false
    # Show user switching menu as icon
    defaults write "$USERPREFS/.GlobalPreferences" userMenuExtraStyle -int 2

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
    # Disable smart addresses
    defaults write "$USERPREFS/com.apple.mail-shared" AddressDisplayMode -int 3
    # Disable remote content
    defaults write "$USERPREFS/com.apple.mail-shared" DisableURLLoading -bool true
    # Disable auto open files in safari
    defaults write "$USERPREFS/com.apple.Safari" AutoOpenSafeDownloads -bool false
    # Enable Develop menu by default
    defaults write "$USERPREFS/com.apple.Safari" IncludeDevelopMenu -bool true
    # Always show full URL
    defaults write "$USERPREFS/com.apple.Safari" ShowFullURLInSmartSearchField -bool true
    # Disable Spotlight suggestions
    defaults write "$USERPREFS/com.apple.Safari" UniversalSearchEnabled -bool false
    defaults write "$USERPREFS/com.apple.lookup" lookupEnabled -dict suggestionsEnabled 0
    defaults write "$USERPREFS/com.apple.lookup.shared" LookupSuggestionsDisabled -bool true
    defaults write "$USERPREFS/com.apple.Spotlight" version -int 7
    defaults write "$USERPREFS/com.apple.Spotlight" orderedItems '(
        { enabled = 1; name = APPLICATIONS; },
        { enabled = 0; name = "MENU_SPOTLIGHT_SUGGESTIONS"; },
        { enabled = 1; name = "MENU_CONVERSION"; },
        { enabled = 1; name = "MENU_EXPRESSION"; },
        { enabled = 1; name = "MENU_DEFINITION"; },
        { enabled = 1; name = "SYSTEM_PREFS"; },
        { enabled = 1; name = DOCUMENTS; },
        { enabled = 1; name = DIRECTORIES; },
        { enabled = 1; name = PRESENTATIONS; },
        { enabled = 1; name = SPREADSHEETS; },
        { enabled = 1; name = PDF; },
        { enabled = 1; name = MESSAGES; },
        { enabled = 1; name = CONTACT; },
        { enabled = 1; name = "EVENT_TODO"; },
        { enabled = 1; name = IMAGES; },
        { enabled = 1; name = BOOKMARKS; },
        { enabled = 1; name = MUSIC; },
        { enabled = 1; name = MOVIES; },
        { enabled = 1; name = FONTS; },
        { enabled = 1; name = "MENU_OTHER"; },
        { enabled = 0; name = "MENU_WEBSEARCH"; }
    )'
    # Disable OCSP
    defaults write "$USERPREFS/com.apple.security.revocation" OCSPStyle -string "None"
    # Disable handover by default
    defaults -currentHost write "$USERPREFS/ByHost/com.apple.coreservices.useractivityd" ActivityAdvertisingAllowed -bool false
    defaults -currentHost write "$USERPREFS/ByHost/com.apple.coreservices.useractivityd" ActivityReceivingAllowed -bool false

    # Disable bash sessions
    touch "$USERHOME/.bash_sessions_disable"

}

if [[ "$(whoami)" != "root" ]]; then
    set_user_defaults
    exit 0
fi

if [[ -s /Library/Custom/postinstall.conf ]]; then
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

while [[ ! -f /var/run/resolv.conf ]]; do sleep 10; done

#
# Set computer name
#

HOSTNAME="$(hostname)"
echo "Set HostName: ${HOSTNAME}"

scutil --set HostName "${HOSTNAME}"
scutil --set ComputerName "${HOSTNAME%%.*}"
scutil --set LocalHostName "${HOSTNAME%%.*}"

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

set_system_defaults
set_user_defaults

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
