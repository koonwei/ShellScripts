#!/bin/sh
#================================================================
#- IMPLEMENTATION
#-    version        1.0
#-    author 	     koon.w.teo
#-    filename       
#================================================================
#  HISTORY
#================================================================
function setHeaders {
	echo "Job_Name, Process Names" > batchname.csv

}
function getFile {

	readarray -t files < files.txt
	
	for file in "${files[@]}";do                                                      
 		lines=$(find "ctrlm/$file" | wc -l)
			if [ $lines -eq 0 ]; then
				tempfile="Not Found"
			else
				tempfile=$(grep -Po 'process.name=\K[^ ]+' "ctrlm/$file")
			fi
		echo ${tempfile}
		echo $file , ${tempfile} >> batchname.csv	
	done 

}
setHeaders
getFile
