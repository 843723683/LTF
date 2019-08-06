#!/bin/bash
# Author: Lz <lz843723683@163.com>
# Note: This was a known issue in CentOS 6.0

echo "Running $0 -  check that bash version info is the same with upstream."

bash --version | grep -qE "(i386|i686|x86_64|aarch64|armv7hl|powerpc64le|powerpc64)-kylin-linux-gnu"

exit $?
