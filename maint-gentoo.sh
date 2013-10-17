#!/bin/bash
ionice -c3 nice -n9 emaint all
ionice -c3 nice -n9 eclean distfiles
ionice -c3 nice -n9 eclean packages
ionice -c3 nice -n9 python-updater
