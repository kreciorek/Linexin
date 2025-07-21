#!/usr/bin/env bash

rum wine-affinity "$HOME/.WineAffinity" winetricks dotnet48 corefonts
mkdir -p "$HOME/.WineAffinity/drive_c/windows/system32/WinMetadata"
git clone https://github.com/daniel080400/AffinityLinuxTut
cd AffinityLinuxTut
unzip WinMetadata.zip
cp -rf WinMetadata "$HOME/.WineAffinity/drive_c/windows/system32/WinMetadata"
rum wine-affinity "$HOME/.WineAffinity" wine winecfg -v win11
