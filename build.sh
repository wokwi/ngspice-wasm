#!/bin/bash

# Script based on EESIM's run.sh: https://github.com/danchitnis/EEsim/tree/main/Docker

#NGSPICE_HOME="https://github.com/danchitnis/ngspice-sf-mirror"
NGSPICE_HOME="https://git.code.sf.net/p/ngspice/ngspice"
NGSPICE_BRANCH="minimal-ngspice"

source /opt/emsdk/emsdk_env.sh

echo "Cloning ngspice from $NGSPICE_HOME, branch $NGSPICE_BRANCH"

cd /opt

git clone --depth 1 --branch $NGSPICE_BRANCH $NGSPICE_HOME ngspice

cd ngspice

#https://www.cyberciti.biz/faq/how-to-use-sed-to-find-and-replace-text-in-files-in-linux-unix-shell/
#https://sourceforge.net/p/ngspice/patches/99/
sed -i 's/-Wno-unused-but-set-variable/-Wno-unused-const-variable/g' ./configure.ac
sed -i 's/AC_CHECK_FUNCS(\[time getrusage\])/AC_CHECK_FUNCS(\[time\])/g' ./configure.ac
sed -i 's|#include "ngspice/ngspice.h"|#include <emscripten.h>\n\n#include "ngspice/ngspice.h"|g' ./src/frontend/control.c
sed -i 's|freewl = wlist = getcommand(string);|emscripten_sleep(100);\n\n\t\tfreewl = wlist = getcommand(string);|g' ./src/frontend/control.c

./autogen.sh
mkdir release
cd release

emconfigure ../configure --disable-debug

wait

sed -i 's|$(ngspice_LDADD) $(LIBS)|$(ngspice_LDADD) $(LIBS) -g1 -s ASYNCIFY=1 -s ASYNCIFY_ADVISE=0 -s ASYNCIFY_IGNORE_INDIRECT=0 -s  ENVIRONMENT="web,worker" -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -s EXPORT_ES6=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=["FS","Asyncify"] -o spice.mjs|g' ./src/Makefile

emmake make

wait

cd src
mv spice.mjs spice.js
mkdir -p /mnt/build
cp spice.js spice.wasm /mnt/build
