#!/bin/bash
echo "#####################################"
echo "# Removing Makefile and Xcode Project"
echo "#####################################"
sudo rm -rfd *.xcodeproj

rm moc_*.cpp
rm qrc_*.cpp
rm ui_*.h
rm *.plist
rm *.o
rm -rfd *.app
