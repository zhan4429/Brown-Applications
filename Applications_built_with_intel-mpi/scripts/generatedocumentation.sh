#! /bin/bash

# This script generates documentation files based on the names of the missing intel-mpi folders in listofmissingfolders.txt and then updates index.rst
# listofmissingfiles.txt can be generated using generatelistofmissingfolders.sh
# Example Usage: ./generatedocumentation.sh
# Warning: Will not work if listofmissingfolders.txt does not exist
# Verify intel-mpi input and documentation output paths before running

# Generate documentation for missing files in intel-mpi using listofmissingfolders.txt

readarray -t listofmissingfolders < listofmissingfolders.txt

for foldername in ${listofmissingfolders[@]}; do
   echo ""
   echo $foldername
   workingdirectory=$PWD
   
   cd /opt/spack/modulefiles/intel-mpi/$foldername/intel
   innermostfoldername=`ls`
   echo "innermostfoldername: $innermostfoldername"
   cd $innermostfoldername
   corefiles=$PWD
   echo "pwd: $PWD"
   cd "$workingdirectory"
   foldernameshortened="${foldername::-12}"
   mkdir -p /home/$USER/Brown-Applications/Applications_built_with_intel-mpi/source/$foldernameshortened
   gitfolders="../source/$foldernameshortened"

   # diff -q $gitfolders $corefiles | grep "Only in" > tempfile.txt
   diff -x '*.lua' -q $gitfolders $corefiles | grep "Only in /opt/" > tempfile.txt

   awk 'NF{ print $NF }' tempfile.txt > listofmissingfiles-$foldernameshortened.txt

   rm tempfile.txt

   readarray -t listofmissingfiles < listofmissingfiles-$foldernameshortened.txt

   for filename in ${listofmissingfiles[@]}; do
      echo ""
      echo $filename
      
      inputfolder="/opt/spack/modulefiles/intel-mpi/$foldername/intel/$innermostfoldername/$filename/"
      echo "input folder: "$inputfolder

      filenamesarray=`ls $inputfolder*.lua`
      for eachfile in $filenamesarray
      do
         inputpath=$eachfile #This assumes last file name in alphabetical order is the file to parse
      done
      echo "input path: "$inputpath
      
      containername=$(echo $inputpath | awk -F/ '{print $9}')

      outputfile="/home/$USER/Brown-Applications/Applications_built_with_intel-mpi/source/$foldernameshortened/$containername/$containername.rst"
      echo "output file: "$outputfile

      inputpathcontent=$(<$inputpath)  

      mkdir -p /home/$USER/Brown-Applications/Applications_built_with_intel-mpi/source/$foldernameshortened/$containername

      echo ".. _backbone-label:" > "$outputfile"
      echo "" >> "$outputfile"
      echo "${containername^}" >> "$outputfile"
      echo "==============================" >> "$outputfile"
      echo "" >> "$outputfile"

      bellfile="/home/$USER/Bell_Application/Applications_built_with_intel-mpi/source/$foldername/$containername/$containername.rst"
      if test -f "$bellfile"; then
         echo "$containername exists in Bell."

         if grep -q -i description "$bellfile"; then
            echo "Description was found in bell file" # Description was found
            sed -n '/Description/,/Versions and Dependencies/p' "$bellfile" | head -n -1 >> "$outputfile" # Grabbing description from file in bell
         else
            echo "description not found in bell file"
            if grep -q -i description "$inputpath"; then
               echo "Description was found in .lua file" # Description was found
               echo "Description" >> "$outputfile"
               echo "~~~~~~~~" >> "$outputfile"
               description=$(cat $inputpath | grep -i "description")
               echo "${description##*:}" | sed -e 's/)//g' -e 's/(//g' -e 's/"//g' -e "s/'//g" -e 's/]//g' -e 's/^[ \t]*//;s/[ \t]*$//' >> "$outputfile"
               echo "" >> "$outputfile"
            else
               echo "description not found in .lua file"   
            fi
         fi
         
      else
         echo "$containername does not exist in Bell."
         
         if grep -q -i description "$inputpath"; then
            echo "Description was found in .lua file" # Description was found
            echo "Description" >> "$outputfile"
            echo "~~~~~~~~" >> "$outputfile"
            description=$(cat $inputpath | grep -i "description")
            echo "${description##*:}" | sed -e 's/)//g' -e 's/(//g' -e 's/"//g' -e "s/'//g" -e 's/]//g' -e 's/^[ \t]*//;s/[ \t]*$//' >> "$outputfile"
            echo "" >> "$outputfile"
         else
            echo "description not found .lua file"   
         fi
      fi

      echo "Versions and Dependencies" >> "$outputfile"
      echo "~~~~~~~~" >> "$outputfile"
      tempv=notfound
      for eachfile in $filenamesarray
      do
         echo -n "- " >> "$outputfile"
         eachfile2=$eachfile
         eachfile=${eachfile::-4}
         echo "$eachfile" | sed 's:.*/::' >> "$outputfile"
         # echo "$eachfile" | sed 's:.*/::'
         if grep -q -i depends_on "$eachfile2"; then
            echo "depends_on found for $eachfile2"
            depends_on=$(cat $eachfile2 | grep -i "depends_on")
            echo "${depends_on##*:}" | sed -e 's/depends_on//g' -e 's/"//g' -e "s/'//g" -e 's/)//g' -e 's/(//g' -e 's/^/   #. /' >> "$outputfile"
            echo "" >> "$outputfile"
            tempv=found
         else
            echo "depends_on not found for $eachfile2"   
            tempv=notfound
         fi
         
      done
      if [ "$tempv" == "notfound" ]; then
         echo "" >> "$outputfile"
      fi
      echo "Module" >> "$outputfile"
      echo "~~~~~~~~" >> "$outputfile"
      echo "You can load the modules by::" >> "$outputfile"
      echo "" >> "$outputfile"
      echo "    module load $containername" >> "$outputfile"
      echo "" >> "$outputfile"

   done

done


# Update index.rst for entire Brown-Applications

workingdirectory=$PWD
mainfolder="/home/$USER/Brown-Applications/"
indexfile="/home/$USER/Brown-Applications/index.rst"

cd $mainfolder
subfoldersarray=`ls -d */`

sed -i '/.. toctree::/,$d' $indexfile

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for eachfolder in $subfoldersarray
do
   echo "each folder : $eachfolder"

   if [[ "$eachfolder" == "Applications_built_with_gcc/" || "$eachfolder" == "Applications_built_with_intel/" || "$eachfolder" == "Applications_built_with_intel-mpi/" || "$eachfolder" == "Applications_built_with_openmpi/" ]];
   then
      echo "if condition met"
      # echo ".. toctree::" >> $indexfile
      eachfolderwithspaces="${eachfolder//_/ }"
      # echo "   :caption: "${eachfolderwithspaces::-1}"" >> $indexfile
      # echo "   :maxdepth: 3" >> $indexfile
      # echo "   :titlesonly:" >> $indexfile
      # echo "   " >> $indexfile
      sourcefolder="/home/$USER/Brown-Applications/"$eachfolder"""source/"
      subfoldersnamearray=`ls -1v "$sourcefolder"`
      for eachsubfolder in $subfoldersnamearray
      do
         echo ".. toctree::" >> $indexfile
         echo "   :caption: "${eachfolderwithspaces::-1}": $eachsubfolder" >> $indexfile
         echo "   :titlesonly:" >> $indexfile
         echo "   " >> $indexfile
         # echo "   $eachfolder""source/$eachsubfolder/" >> $indexfile
         filenamesarray=`ls "$sourcefolder"/$eachsubfolder`

         for eachfile in $filenamesarray
         do
            echo "   $eachfolder""source/$eachsubfolder/$eachfile/$eachfile" >> $indexfile
         done
         
         echo "" >> $indexfile
      done

      
   else
      echo "if condition not met"
      echo ".. toctree::" >> $indexfile
      eachfolderwithspaces="${eachfolder//_/ }"
      echo "   :caption: "${eachfolderwithspaces::-1}"" >> $indexfile
      # echo "   :maxdepth: 3" >> $indexfile
      echo "   :titlesonly:" >> $indexfile
      echo "   " >> $indexfile
      sourcefolder="/home/$USER/Brown-Applications/"$eachfolder"""source/"

      echo "source folder : $sourcefolder"
      filenamesarray=`ls "$sourcefolder"`
      for eachfile in $filenamesarray
      do
         echo "   $eachfolder""source/$eachfile/$eachfile" >> $indexfile
      done
      echo "" >> $indexfile
   fi   

done
IFS=$SAVEIFS

cd "$workingdirectory"