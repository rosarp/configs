#!/usr/bin/env nu

sudo systemctl daemon-reload
sudo apt-get update
sudo apt-get upgrade
sudo apt-get autoremove
flatpak update
sudo snap refresh
snap list --all | detect columns | where Notes =~ "disabled" | each {|snp| sudo snap remove $snp.Name $"--revision=($snp.Rev)" }
# snap list --all | while read snapname ver rev trk pub notes; do if [[ $notes = *disabled* ]]; then sudo snap remove "$snapname" --revision="$rev"; fi; done
# sudo rm /var/lib/PackageKit/offline-update-competed
