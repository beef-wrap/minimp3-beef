mkdir libs
mkdir libs\debug
mkdir libs\release

copy minimp3\minimp3_ex.h minimp3\minimp3_ex.c

clang -c -O0 -g -gcodeview -o minimp3.lib -target x86_64-pc-windows -fuse-ld=llvm-lib -Wall -DMINIMP3_IMPLEMENTATION minimp3\minimp3_ex.c
move minimp3.lib libs\debug

clang -c -O3 -o minimp3.lib -target x86_64-pc-windows -fuse-ld=llvm-lib -Wall -DMINIMP3_IMPLEMENTATION minimp3\minimp3_ex.c
move minimp3.lib libs\release