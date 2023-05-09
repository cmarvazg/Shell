#!/usr/bin/bash

/usr/bin/dnf    clean all
/usr/bin/dnf -y autoremove
/usr/bin/dnf -y update
shutdown now
