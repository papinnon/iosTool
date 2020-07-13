#!/bin/sh

ipapath=$1
dylib2behook=$2
unzip -q $1
# hook
yololib $ipapath $dylib2behook
# resign
# to be continued
