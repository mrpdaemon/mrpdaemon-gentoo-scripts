#!/bin/bash

PREXCLUDEPATH="/etc/portage/preserved-rebuild.exclude"

if [ "$1" != "--no-sync" ] ; then
   layman -S || { echo "Layman failed"; exit 1;}
   eix-sync || { echo "eix-sync failed"; exit 1;}
fi

# Check if DISTCC is used
USE_DISTCC=`grep FEATURES /etc/portage/make.conf | grep distcc`
if [ -n "$USE_DISTCC" ]
then
   DISTCC_CMD="pump"
else
   DISTCC_CMD=""
fi

${DISTCC_CMD} emerge -avuDN --jobs --load-average 9 --with-bdeps=y @world || { echo "emerge failed"; exit 1;}
emerge --ask --depclean || { echo "depclean failed"; exit 1;}

if [ -e "$PREXCLUDEPATH" ]
then
   PREXCLUDE="--exclude `cat \"$PREXCLUDEPATH\"`"
else
   PREXCLUDE=""
fi

${DISTCC_CMD} emerge -a1v --jobs --load-average 9 $PREXCLUDE @preserved-rebuild || { echo "preserved-rebuild failed"; exit 1;}
ionice -c3 revdep-rebuild -i -- --jobs --load-average 9 || { echo "revdep-rebuild failed"; exit 1;}
