# fltk cross compile from linux to windows

Tested on fedora.

Assume that:
- fltk win32 target is installed to `i686-w64-mingw32` directory in `${FLTK_HOME}`;
- cmake toolchain file is located in `~/.config/TC-mingw-i686.cmake`;

```sh
# build fltk
cmake -B i686-w64-mingw32 -DCMAKE_TOOLCHAIN_FILE=~/.config/TC-mingw-i686.cmake
cd i686-w64-mingw32
cmake --build . -j8

# compile other fltk projects
${FLTK_HOME}/i686-w64-mingw32/fltk-config --compile XXX.cxx --link '-static -static-libgcc -static-libstdc++'
```

## content of ...

~/.config/TC-mingw-i686.cmake

<!--
Codegen echo '```'; cat ./TC-mingw-i686.cmake; echo '```'
-->

<!-- Codegen begin -->
```
# copied from cmake homepage, slightly modified

# the name of the target operating system
set(CMAKE_SYSTEM_NAME Windows)

# which compilers to use for C and C++
set(CMAKE_C_COMPILER   i686-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER i686-w64-mingw32-g++)

# where is the target environment located
set(CMAKE_FIND_ROOT_PATH  /usr/i686-w64-mingw32
    )

# adjust the default behavior of the FIND_XXX() commands:
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_EXE_LINKER_FLAGS "-static -static-libgcc -static-libstdc++")
```
<!-- Codegen end -->
