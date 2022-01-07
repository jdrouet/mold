#!/bin/bash
export LANG=
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/ld64.mold"
t=out/test/macho/$testname
mkdir -p $t

mkdir -p $t/Foo.framework

cat <<EOF | $CC -o $t/Foo.framework/Foo -shared -xc -
#include <stdio.h>
void hello() {
  printf("Hello world\n");
}
EOF

cat <<EOF | $CC -o $t/a.o -c -xc -
void hello();
int main() {
  hello();
}
EOF

cd $t
clang -fuse-ld="$mold" -o $t/exe $t/a.o -Wl,-F. -Wl,-framework,Foo
$t/exe | grep -q 'Hello world'

echo OK
