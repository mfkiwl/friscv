# Install RISCV Toolchain

On MacOs:

````bash
brew install gawk gnu-sed gmp mpfr libmpc isl zlib expat
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv #-enable-multilib to compile also RV32I
sudo make
```

Don't use brew pre-built packages, they are broken

# Utilities

    - riscv64-unkown-elf-addr2line: convert addresses into line / filename pair
    - riscv64-unkown-elf-ar: creates, modifies, and extracts from archives
    - riscv64-unkown-elf-as: converts the assembly code into machine code in the object file
    - riscv64-unkown-elf-c++: c++ compilation toolchain
    - riscv64-unkown-elf-c++filt: Transforming C++ ABI identifiers (like RTTI symbols) into the original C++ source identifiers is called “demangling.”
    - riscv64-unkown-elf-cpp: sounds similar to c++
    - riscv64-unkown-elf-elfedit: update elf header or elf files
    - riscv64-unkown-elf-g++: another g++ toolchain
    - riscv64-unkown-elf-gcc: c toolchain
    - riscv64-unkown-elf-gcc-ar: creates, modifies, and extracts from archives
    - riscv64-unkown-elf-gcc-nm: list symbols in files (a.ouy by default)
    - riscv64-unkown-elf-gcc-ranlib: generate an index to speed access of archives
    - riscv64-unkown-elf-gcov: print code coverage infornation
    - riscv64-unkown-elf-gcov-dump: print coverage file contents
    - riscv64-unkown-elf-gcov-tool: offline tool to handle gcda counts
    - riscv64-unkown-elf-gdb: debugger
    - riscv64-unkown-elf-gprof: ?
    - riscv64-unkown-elf-ld: linker
    - riscv64-unkown-elf-ld-bfd: ?
    - riscv64-unkown-elf-lto-dump: ?
    - riscv64-unkown-elf-nm: list symbols in files (a.ouy by default)
    - riscv64-unkown-elf-objcopy: copy a binary, possibly transforming during the process
    - riscv64-unkown-elf-objdump: display information from object(s)
    - riscv64-unkown-elf-ranlib: generate an index to speed access of archives
    - riscv64-unkown-elf-readelf: display information about the content of elf format files
    - riscv64-unkown-elf-run ? Related to debugging?
    - riscv64-unkown-elf-size: display the siwe of sections into binary files
    - riscv64-unkown-elf-strings: display printable strinfs in files
    - riscv64-unkown-elf-strip: remove symbols and section from files
