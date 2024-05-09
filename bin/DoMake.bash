#!/usr/bin/env bash
BASE=/home/pjoslin/Projects/tmux-themepack
if [ ! -d "$BASE" ]
then
    BASE=/aaahome/pjoslin/Projects/tmux-themepack
fi
(
cd $BASE
make
make install
)

# vim: set ai et nu cin sts=4 sw=4 ts=4 tw=78 filetype=sh :
