#! /bin/bash

# This script generates a list of openmpi folders that are not in the git directory
# The output file is listofmissingfolders.txt and is used in generatedocumentation.sh
# Example usage: ./generatelistofmissingfiles.sh

corefiles="/opt/spack/modulefiles/openmpi/"
gitfolders="../source/"

# diff -q $gitfolders $corefiles | grep "Only in" > tempfile.txt
diff -x '*.lua' -q $gitfolders $corefiles | grep "Only in /opt/" > tempfile.txt

awk 'NF{ print $NF }' tempfile.txt > listofmissingfolders_temp.txt
rm listofmissingfolders.txt
touch listofmissingfolders.txt
readarray -t listofmissingfolders < listofmissingfolders_temp.txt
counter=1;
numberoffiles=0

for foldername in ${listofmissingfolders[@]}; do

   workingdirectory=$PWD
   cd /opt/spack/modulefiles/openmpi/$foldername
   innerfoldername=`ls`
   cd $innerfoldername
   innermostfoldername=`ls`
   corefiles=$PWD
   cd "$workingdirectory"
   
   tempnumber=`ls /opt/spack/modulefiles/openmpi/$foldername/$innerfoldername/$innermostfoldername/ | wc -l`
   echo "temp number: $tempnumber"
   if [[ "$tempnumber" -gt "$numberoffiles" ]]; then
      numberoffiles=$tempnumber
      foldertobewritten="$foldername"
   fi
   echo "Number of files: $numberoffiles"
   counter=$counter+1
   if [[ "$counter" -eq 19 ]]; then
      echo "$foldertobewritten" >> listofmissingfolders.txt
      counter=1
      numberoffiles=0
   fi

done



rm tempfile.txt
rm listofmissingfolders_temp.txt