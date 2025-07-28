#!/usr/bin/env bash

rum wine-affinity "$HOME/.WineAffinity" winetricks dotnet48 corefonts
mkdir -p "$HOME/.WineAffinity/drive_c/windows/system32/WinMetadata"
git clone https://github.com/daniel080400/AffinityLinuxTut
unzip AffinityLinuxTut/WinMetadata.zip
rum wine-affinity $HOME"/.WineAffinity" wine winecfg -v win11
cp -rf AffinityLinuxTut/WinMetadata $HOME"/.WineAffinity/drive_c/windows/system32"
rum affinity-photo3-wine9.13-part3 /home/petexy/.wineAffinity winetricks renderer=vulkan
rm -rf AffinityLinuxTut
