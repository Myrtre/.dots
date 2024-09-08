# Add ~/.guix_profile if it exists
if [ -L ~/.guix-profile ];then
    GUIX_PROFILE="/home/davy/.guix-profile"
    . $GUIX_PROFILE/etc/profile""
fi

# StumpWM - Set Title Bar of GTK Application
export GTK_THEME=Adwaita:dark
