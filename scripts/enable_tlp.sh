#!/bin/bash

sudo systemctl enable tlp.service
sudo systemctl start tlp.service
systemctl enable NetworkManager-dispatcher.service
systemctl enable NetworkManager-dispatcher.service

sudo tlp-stat -p
sudo tlp-stat -s

sudo cp ~/dotfiles/tlp/tlp.conf /etc/tlp.conf

sudo systemctl restart tlp.service
