#!/bin/sh

# Install base Steam and some of their dependencies
flatpak install flathub com.valvesoftware.Steam \
        org.freedesktop.Platform.VulkanLayer.MangoHud \
        org.freedesktop.Platform.VulkanLayer.vkBasalt \
        org.freedesktop.Platform.VulkanLayer.gamescope \
        com.github.Matoking.protontricks \
        net.davidotek.pupgui2

#sudo echo "alias steam='flatpak run com.valvesoftware.Steam'" >> ~/.bashrc
#sudo echo "alias steam-console='flatpak run --command='/bin/sh' com.valvesoftware.Steam'" >> ~/.bashrc
