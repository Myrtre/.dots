(define-module (myr system jottunheim))
(use-modules (gnu)
	     (gnu packages)
	     (gnu services)
	     (gnu system)
	     (gnu system nss)
	     (gnu system setuid)
	     (guix download)
	     (guix packages)
	     (nongnu packages linux)
	     (nongnu system linux-initrd))

(use-package-modules lisp lisp-xyz wm xorg xdisorg linux fonts
		     cups suckless networking curl emacs vim
		     version-control nfs file-systems compression
		     package-management libusb display-managers
             shells tls music)

(use-service-modules cups ssh desktop xorg nix
		     networking sddm pm)

(define %keyboard-layout
  (keyboard-layout "hu"))

(define %davy-user-account
  (list (user-account
	 (name "davy")
	 (comment "MYRtré")
	 (group "users")
	 (supplementary-groups '("wheel"
				 "netdev"
				 "lp"
				 "tty"
				 "kvm"
				 "input"
				 "realtime"
				 "audio" "video"))
	 (home-directory "/home/davy"))))

(define %jottunheim-file-system
  (list (file-system
         (mount-point "/")
         (device (file-system-label "guix-linux"))
	 (options "subvol=@,compress=lzo,discard=async,space_cache=v2")
         (type "btrfs"))
	(file-system
         (mount-point "/home")
         (device (file-system-label "guix-linux"))
	 (options "subvol=@home,compress=zstd")
         (type "btrfs"))
	(file-system
         (mount-point "/gnu")
         (device (file-system-label "guix-linux"))
	 (options "subvol=@gnu,compress=lzo,discard=async,space_cache=v2")
         (type "btrfs"))
	(file-system
         (mount-point "/var/logs")
         (device (file-system-label "guix-linux"))
	 (options "subvol=@logs,compress=lzo,space_cache=v2")
         (type "btrfs"))
        (file-system
         (mount-point "/boot/efi")
         (device (uuid "D259-76BF"
                       'fat32))
         (type "vfat"))))


(define %stumpwm-packages
  (list sbcl                   ;;|--> gnu packages lisp
	sbcl-slynk             ;;|--> gnu packages lisp-xyz
	sbcl-parse-float
	sbcl-local-time
	sbcl-cl-ppcre
	sbcl-zpng
	sbcl-salza2
	sbcl-clx
	sbcl-zpb-ttf
	sbcl-cl-vectors
	sbcl-cl-store
	sbcl-trivial-features
	sbcl-bordeaux-threads
	sbcl-cl-fad
	sbcl-clx-truetype
    sbcl-cl+ssl
	sbcl-alexandria
	stumpwm+slynk))          ;;|--> gnu packages wm

(define %font-packages
  (list font-hermit        ;;|--> gnu packages fonts
	font-jetbrains-mono
	font-hack
	font-iosevka-aile
	font-google-noto   ;;:icons
	font-google-noto-emoji
	font-google-noto-sans-cjk
	font-google-material-design-icons
	font-awesome
	font-openmoji))

(define %x11-util-packages
  (list xterm               ;;|--> gnu packages xorg
	transset
	setxkbmap
	xhost
	xsetroot
	xinput
	xrdb
	xset
	xrandr
	xinit
	xorg-server
	xorg-server-xwayland
	xclip              ;;|--> gnu packages xdisorg
	xsel
	xss-lock
	sddm               ;;|--> gnu packages display-managers
	sugar-dark-sddm-theme
	guix-simplyblack-sddm-theme
	sddm-qt5))

(define %system-packages
  (list curl               ;;|--> gnu packages curl
	git                ;;|--> gnu packages version-control
	bluez              ;;|--> gnu packages networking
	blueman
	exfat-utils        ;;|--> gnu packages file-systems
	fuse-exfat         ;;|--> gnu packages linux
	btrfs-progs
	ntfs-3g
	brightnessctl
    playerctl          ;;|--> gnu packages music
    i3lock             ;;|--> gnu packages wm
    i3lock-fancy
    openssl            ;;|--> gnu packages tls
    fish               ;;|--> gnu packages shells
	stow               ;;|--> gnu packages stow
	emacs              ;;|--> gnu packages emacs
	vim                ;;|--> gnu packages vim
	zip unzip))        ;;|--> gnu packages compression

(define (substitutes->services config)
  (guix-configuration
   (inherit config)
   (substitute-urls
    (cons* "https://substitutes.nonguix.org"
	   %default-substitute-urls))
   (authorized-keys
    (cons* (origin
	    (method url-fetch)
	    (uri "https://substitutes.nonguix.org/signing-key.pub")
	    (file-name "nonguix.pub")
	    (sha256
	     (base32
	      "0j66nq1bxvbxf5n8q2py14sjbkn57my0mjwq7k1qm9ddghca7177")))
	   %default-authorized-guix-keys))))

;; For Laptop Touchpad
(define %additional-xorg-configuration
  "Section \"InputClass\"
   Identifier \"Touchpads\"
   Driver \"libinput\"
   MatchDevicePath \"/dev/input/event*\"
   MatchIsTouchpad \"on\"

   Option \"DisableWhileTyping\" \"on\"
   Option \"MiddleEmulation\" \"on\"
   Option \"ClickMethod\" \"clickfinger\"
   Option \"Tapping\" \"on\"
   Option \"TappingButtonMap\" \"lrm\"
   Option \"TappingDrag\" \"on\"
   Option \"ScrollMethod\" \"twofinger\"
   Option \"NaturalScrolling\" \"true\"
   EndSection")

(define %system-services
  (cons* (service nix-service-type)	    ;; --> Nix Package Manager
         ;; --> Screen-Locker
	     (service screen-locker-service-type
		          (screen-locker-configuration
		           (name "i3lock")
		           (program (file-append i3lock "/bin/i3lock"))))
         ;; --> Bluetooth-Service
	     (service bluetooth-service-type
		          (bluetooth-configuration
		           (auto-enable? #t)))
         ;; --> Printing Service
	     (service cups-service-type
		          (cups-configuration
		           (web-interface? #t)
		           (default-paper-size "Letter")))
         ;; --> Mount deps
	     (simple-service 'mount-helpers
			             privileged-program-service-type
			             (map (lambda (program)
				                (setuid-program
				                 (program program)))
			                  (list (file-append nfs-utils "/sbin/mount.nfs")
				                    (file-append ntfs-3g "/sbin/mount.ntfs-3g"))))
         ;; --> Power-Manager
         (service thermald-service-type)
         (service tlp-service-type
                  (tlp-configuration
                   (cpu-boost-on-ac? #t)
                   (wifi-pwr-on-bat? #t)))
         ;; --> Jack plugin
	     (service pam-limits-service-type
		          (list
		           (pam-limits-entry "@realtime" 'both 'rtprio 99)
		           (pam-limits-entry "@realtime" 'both 'memlock 'unlimited)))
         
	     (simple-service 'mtp udev-service-type (list libmtp))
         
	     (udev-rules-service 'pipewire-add-udev-rules pipewire)
	     (udev-rules-service 'brightnessctl-udev-rules brightnessctl)
	     ;; --> Xorg 
	     (service xorg-server-service-type)
         ;; --> Display-Manager
         (service sddm-service-type
                  (sddm-configuration
		           (sddm sddm-qt5)
                   (theme "sugar-dark")
	               (xorg-configuration
	                (xorg-configuration
			         (keyboard-layout %keyboard-layout)
			         (extra-config (list %additional-xorg-configuration))))))
	     ;; --> SSH
	     (service openssh-service-type)
         ;; Remove gdm- etc.
         (modify-services %desktop-services
			              (delete gdm-service-type)
			              (guix-service-type
			               config =>
			               (substitutes->services config)))))

(operating-system
 (kernel linux-6.10)
 (initrd microcode-initrd)
 ;; Fixes Xorg Lagg
 (kernel-arguments (cons* "i915.enable_psr=0"
                          "i915.i915_enable_fbc=1"
                          %default-kernel-arguments))
 (firmware (list linux-firmware
		 amdgpu-firmware
		 iwlwifi-firmware
		 ibt-hw-firmware))
 (locale "en_US.utf8")
 (timezone "Europe/Budapest")
 (keyboard-layout %keyboard-layout)
 (host-name "jotunheim")

 (users (append
	 %davy-user-account
	 %base-user-accounts))

 (groups (cons (user-group (system? #t) (name "realtime"))
	       %base-groups))
 
 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
 
 (swap-devices (list (swap-space
                      (target (uuid
                               "09451d9c-5cc9-4d1a-aacf-f48da883157e")))))

 (file-systems (append
		%jottunheim-file-system
		%base-file-systems))

 (packages (append
	    %stumpwm-packages
	    %x11-util-packages
	    %font-packages
	    %system-packages
	    %base-packages))

 (services %system-services)

 (name-service-switch %mdns-host-lookup-nss))
