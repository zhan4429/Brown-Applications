#! /bin/bash

# This script generates a list of Core files that are not in the git directory
# The output file is listofmissingfiles.txt and is used in generatedocumentation.sh
# Example usage: ./generatelistofmissingfiles.sh

corefiles="/opt/spack/modulefiles/Core/"
gitfolders="../source/"

# diff -q $gitfolders $corefiles | grep "Only in" > tempfile.txt
diff -x '*.lua' -q $gitfolders $corefiles | grep "Only in /opt/" > tempfile.txt

awk 'NF{ print $NF }' tempfile.txt > listofmissingfiles.txt

rm tempfile.txt