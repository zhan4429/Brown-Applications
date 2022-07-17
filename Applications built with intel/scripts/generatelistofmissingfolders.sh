#! /bin/bash

# This script generates a list of intel folders that are not in the git directory
# The output file is listofmissingfolders.txt and is used in generatedocumentation.sh
# Example usage: ./generatelistofmissingfiles.sh

corefiles="/opt/spack/modulefiles/intel/"
gitfolders="../source/"

# diff -q $gitfolders $corefiles | grep "Only in" > tempfile.txt
diff -x '*.lua' -q $gitfolders $corefiles | grep "Only in /opt/" > tempfile.txt

awk 'NF{ print $NF }' tempfile.txt > listofmissingfolders.txt

rm tempfile.txt