{ config, lib, pkgs ? import <nixpkgs-unstable> , ...}:
{
  home.username = "davy";
  home.homeDirectory = "/home/davy";

  home.packages = with pkgs; [
    ## -- Dependencies -- ## 
    nerdfonts
    ## -- Apps -- ##
  ];
 
  
  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
}
