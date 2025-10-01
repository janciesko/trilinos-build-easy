# trilinos-build-easy

This project provides an example configuration of the Trilinos numerical library[^1] and helper scripts.

## Example use
```
#!/bin/bash
export TRILINOS_HOME=`PATH_TO_TRILINOS`
export TRILINOS_BUILD_EASY_HOME=`TRILINOS_BUILD_EASY`
cd $TRILINOS_BUILD_EASY_HOME
source env.sh
configure_trilinos
build_trilinos
```
[^1]: https://github.com/trilinos/Trilinos
