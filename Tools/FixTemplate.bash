#!/usr/bin/env bash

BASE="/home/pjoslin/Projects/TMUXTHEMES/tmux-themepack/src"

for i in *;
do
    if [ -f "$i" ] ;
    then
        DIR=$PWD
        DIR=${DIR##$BASE}
        mv $i /tmp ;
        echo "#################### File: $DIR/$i" >> $i ;
        grep -v "File: " /tmp/$i >> $i ;
        echo "#################### End File: $DIR/$i" >> $i ;
        fi ;
    done
    # vim: set ai et nu cin sts=4 sw=4 ts=4 tw=78 filetype=sh :
