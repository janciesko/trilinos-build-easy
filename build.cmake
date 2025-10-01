
set(CMAKE_INSTALL_PREFIX "$ENV{TRILINOS_INSTALL_DIR}")
set(BUILD_SHARED_LIBS OFF)


message(STATUS "The value of MY_VARIABLE is: ${CMAKE_CURRENT_LIST_DIR}")

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/cmake/SetUtils.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/cmake/tpls.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/cmake/basePackages.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/cmake/tpetraStack.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/cmake/cuda.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/cmake/deprecated.cmake")
