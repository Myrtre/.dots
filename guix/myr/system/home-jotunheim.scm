(define-module (myr system home-jotunheim))
(use-modules (gnu)
             ((myr utils) #:select (gather-manifest-packages))
             (myr services emacs)
             (myr services udiskie)
	         (gnu home)
	         (gnu home services)
	         (gnu home services desktop)
	         (gnu home services sound)
	         (gnu home services shells)
	         (gnu home services gnupg)
	         (gnu home services xdg)
	         (guix gexp)
	         (guix transformations))

(use-package-modules fonts web-browsers gnuzilla gnupg mail pulseaudio
		     gstreamer compton image-viewers linux music kde
		     gimp inkscape graphics compression version-control
		     guile guile-xyz emacs emacs-xyz audio video rust-apps
		     gnome gnome-xyz kde-frameworks freedesktop package-management
		     curl wget ssh glib librewolf xdisorg
             wm shells)

(define %font-packages
  (list font-hermit        ;;|--> gnu packages fonts
	font-hack
	font-iosevka-aile
	font-google-noto       ;;:icons
	font-google-noto-emoji
	font-google-noto-sans-cjk
	font-google-material-design-icons
	font-awesome
	font-openmoji))

(define %media-packages
  (list gstreamer       ;;|--> gnu packages gstreamer
	gst-plugins-ugly
	gst-plugins-bad
	gst-plugins-base
	gst-plugins-good
	gst-libav
	alsa-utils       ;;|--> gnu packages linux
	pipewire
	wireplumber
	brightnessctl
	picom            ;;|--> gnu packages compton
	pavucontrol      ;;|--> gnu packages pulseaudio
	mpv              ;;|--> gnu packages video :apps
	playerctl        ;;|--> gnu packages music
	feh              ;;|--> gnu packages image-viewer
	sxiv))           

(define %general-packages
  (list curl            ;;|--> gnu packages curl
	ripgrep         ;;|--> gnu packages rust-apps
	wget            ;;|--> gnu packages wget
	openssh         ;;|--> gnu packages ssh
	zip             ;;|--> gnu packages compression
	unzip
	git             ;;|--> gnu packages version-control
	gnupg           ;;|--> gnu packages gnupg
	pinentry
	pinentry-tty
    fish            ;;|--> gnu packages wm
    polybar
    rxvt-unicode))  ;;|--> gnu packages xdisorg

(define %appearance-packages
  (list adwaita-icon-theme    ;;|--> gnu packages gnome
	papirus-icon-theme    ;;|--> gnu packages gnome-xyz
	breeze-icons))        ;;|--> gnu packages kde-frameworks

(define %xdg-packages
  (list xdg-desktop-portal
	xdg-utils
	xdg-dbus-proxy
	shared-mime-info
    flatpak               ;;|--> gnu packages package-management
    flatpak-xdg-utils))   ;;|--> gnu packages freedesktop

(home-environment
 (packages (append (gather-manifest-packages '(mail-manifest
                                               app-manifest
                                               ;; move gaming-manifest to Flatpak...
                                               ))
		  (append %media-packages
			  %general-packages
			  %appearance-packages
			  %xdg-packages)))
 (services
  (list (service home-dbus-service-type)
	    (service home-pipewire-service-type)
        (service home-emacs-config-service-type)
        (service home-udiskie-service-type)
	    (service home-gpg-agent-service-type
		         (home-gpg-agent-configuration
		          (pinentry-program
		           (file-append pinentry-emacs "/bin/pinentry-emacs"))
		          (ssh-support? #t)))
	    (service home-x11-service-type)
	    (simple-service 'env-vars home-environment-variables-service-type
			            '(("EDITOR" . "emacsclient -c -a 'emacs'")
			              ("BROWSER" . "nyxt")
                          ("PATH" . "$HOME/.bin:$HOME/.npm-global/bin:$PATH")
                          ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share")
			              ("XDG_SESSION_TYPE" . "x11")
			              ("XDG_SESSION_DESKTOP" . "stumpwm")
			              ("XDG_CURRENT_DESKTOP" . "stumpwm")
                          ("XDG_PROJECTS_DIR" . "~/projects")
			              ("XDG_CACHE_DIR" . "~/.cache")))
	    (simple-service 'xdg-usr-dirs home-xdg-user-directories-service-type
			            (home-xdg-user-directories-configuration
			             (desktop      "$HOME/desktop")
			             (documents    "$HOME/docs")
			             (pictures     "$HOME/pics")
			             (videos       "$HOME/vids")
			             (templates    "$HOME/temp")
			             (music        "$HOME/music")
			             (publicshare  "$HOME" )
			             (download     "$HOME/downloads")))
	    (service home-bash-service-type
		         (home-bash-configuration
		          (guix-defaults? #f)
		          (aliases '(("grep" . "grep --color=auto")
			                 ("ls" . "ls -p --color=auto")
			                 ("ll" . "ls -l")
			                 ("la" . "ls -la")
			                 ("ghr" . "guix home reconfigure")
			                 ("gsr" . "sudo guix system reconfigure")
			                 ("gup" . "guix pull && guix upgrade")
			                 ("gud" . "guix system delete-generations")
			                 ("ghd" . "guix home delete-generations")))
		          (bashrc
		           (list (local-file "../../.files/dot-bashrc.sh"
				                     #:recursive? #t)))
		          (bash-profile
                   `(,(plain-file "bash-profile-extras"
                                  (string-append
                                   ;; Load the Nix profile
                                   "if [ -f /run/current-system/profile/etc/profile.d/nix.sh ]; then\n"
                                   "   . /run/current-system/profile/etc/profile.d/nix.sh\n"
                                   "fi\n"))
		             ,(local-file "../../.files/dot-bash_profile.sh"
				                     #:recursive? #t))))))))
