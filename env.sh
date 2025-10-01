#source env.sh

#!/bin/bash
#check if TRILINOS_HOME is set. If not error out.
#check if TRILINOS_BUILD_EASY_HOME is set. If not error out.

if [ -z ${TRILINOS_HOME+x} ]; then 
	echo "Please set TRILINOS_HOME. Exiting..." 
	return;
fi

if [ -z ${TRILINOS_BUILD_EASY_DIR+x} ]; then
        echo "Please set TRILINOS_BUILD_EASY_DIR. Exiting..."
        return;
fi

export TRILINOS_BUILD_EASY_DIR=$TRILINOS_BUILD_EASY_HOME
export TRILINOS_DIR=$TRILINOS_HOME
export TRILINOS_BUILD_DIR=$TRILINOS_DIR/build
export TRILINOS_INSTALL_DIR=$TRILINOS_DIR/install

DIR=$TRILINOS_BUILD_EASY_DIR

#Set this to something that is closest where you're running. Examples:
#export ATDM_CONFIG_REGISTER_CUSTOM_CONFIG_DIR=${TRILINOS_DIR}/cmake/std/atdm/contributed/weaver
export ATDM_CONFIG_REGISTER_CUSTOM_CONFIG_DIR=${TRILINOS_DIR}/cmake/std/atdm/contributed/kokkos-dev-2

clear_build() {
    pushd $TRILINOS_BUILD_DIR && rm -rf CMakeCache.txt CMakeFiles/ && popd
}

configure_trilinos() {
    clear_build && cmake -S $TRILINOS_DIR -B $TRILINOS_BUILD_DIR -C $DIR/build.cmake |& tee $TRILINOS_BUILD_DIR/configure.log
}

build_trilinos() {
    pushd $TRILINOS_BUILD_DIR/ && make -j 5 && popd
}
