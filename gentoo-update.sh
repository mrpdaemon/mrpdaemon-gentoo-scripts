#!/bin/bash

PREXCLUDEPATH="/etc/portage/preserved-rebuild.exclude"
DISTCC_NUM_JOBS=9

while [[ $# > 0 ]]
do
key="$1"
case $key in
    -s|--no-sync)
    NO_SYNC=true
    ;;
    -d|--no-distcc)
    NO_DISTCC=true
    ;;
    -j|--no-jobs)
    NO_JOBS=true
    ;;
    -t|--test)
    DRY_RUN=true
    ;;
    -p|--use-packages)
    USE_PACKAGES=true
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

declare -i NUM_JOBS
NUM_JOBS=`cat /proc/cpuinfo | awk '/^processor/{print $3}' | tail -1`
NUM_JOBS=$NUM_JOBS+2

# Check if DISTCC is used
USE_DISTCC=`grep FEATURES /etc/portage/make.conf | grep distcc`
if [ -n "$USE_DISTCC" ]
then
   DISTCC_CMD="pump"
   JOBS_PARAMS="--jobs --load-average ${DISTCC_NUM_JOBS}"
else
   DISTCC_CMD=""
   JOBS_PARAMS="--jobs --load-average ${NUM_JOBS}"
fi

if [ "$NO_DISTCC" = true ]; then
   DISTCC_CMD="FEATURES=\"-distcc\""
   JOBS_PARAMS="--jobs --load-average ${NUM_JOBS}"
fi

if [ "$NO_JOBS" = true ]; then
   JOBS_PARAMS=""
fi

if [ "$DRY_RUN" = true ]; then
   TEST_CMD="echo"
fi

if [ "$NO_SYNC" != true ] ; then
   ${TEST_CMD} emaint sync -a || { echo "emaint sync failed"; exit1;}
fi

if [ "$USE_PACKAGES" = true ]; then
   EMERGE_FLAGS="-auvDNk"
else
   EMERGE_FLAGS="-auvDN"
fi

${TEST_CMD} ${DISTCC_CMD} emerge ${EMERGE_FLAGS} ${JOBS_PARAMS} --with-bdeps=y --complete-graph=y --backtrack=300 @world || { echo "emerge failed"; exit 1;}
${TEST_CMD} emerge --ask --depclean || { echo "depclean failed"; exit 1;}

if [ -e "$PREXCLUDEPATH" ]
then
   PREXCLUDE="--exclude `cat \"$PREXCLUDEPATH\"`"
else
   PREXCLUDE=""
fi

${TEST_CMD} ${DISTCC_CMD} emerge -a1v ${JOBS_PARAMS} $PREXCLUDE @preserved-rebuild || { echo "preserved-rebuild failed"; exit 1;}
${TEST_CMD} ionice -c3 revdep-rebuild -i -- ${JOBS_PARAMS} || { echo "revdep-rebuild failed"; exit 1;}
