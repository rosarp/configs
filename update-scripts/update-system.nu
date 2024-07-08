#!/usr/bin/env nu

sudo systemctl daemon-reload
sudo apt update
sudo apt upgrade
sudo apt autoremove
sudo snap refresh
snap list --all | detect columns | where Notes =~ "disabled" | each {|snp| sudo snap remove $snp.Name $"--revision=($snp.Rev)" }
# snap list --all | while read snapname ver rev trk pub notes; do if [[ $notes = *disabled* ]]; then sudo snap remove "$snapname" --revision="$rev"; fi; done
# sudo rm /var/lib/PackageKit/offline-update-competed
