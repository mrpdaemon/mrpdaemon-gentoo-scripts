#!/bin/bash
if [ "$1" != "--no-sync" ] ; then
   layman -S || { echo "Layman failed"; exit 1;}
   eix-sync || { echo "eix-sync failed"; exit 1;}
fi
/root/portage-cgroup 3 &
emerge -avuDN --jobs --load-average 9 --with-bdeps=y @world || { echo "emerge failed"; exit 1;}
emerge --ask --depclean || { echo "depclean failed"; exit 1;}
/root/portage-cgroup 3 &
emerge -a1v --jobs --load-average 9 @preserved-rebuild || { echo "preserved-rebuild failed"; exit 1;}
ionice -c3 revdep-rebuild -i -- --jobs --load-average 9 || { echo "revdep-rebuild failed"; exit 1;}
