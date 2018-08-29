#!/bin/sh
#================================================================
#- IMPLEMENTATION
#-    version        1.0
#-    author 	     koon.w.teo
#-    filename       
#================================================================
#  HISTORY
#================================================================

function show {    
               echo "++++++++++++++++"
               echo "Usage: -P <Path to XML File> -O <Output CSV Name>" 
               echo "++++++++++++++++"
}

function banner {
	echo "+++++++++++++++++++++++++++++"
	echo "${1}"
	echo "+++++++++++++++++++++++++++++"	
}
errorStatus=0

while getopts :P:O: FLAG
do
    case ${FLAG} in
    P) export xml_name=${OPTARG};;
    O) export output_name=${OPTARG};;
    *) show
       exit 1;;
    esac
done



if [[ -z ${xml_name} || -z ${output_name} ]]; then
      show
      exit
fi
function setHeaders {
	echo "Counter , Job_Name, Job_Entity , Job Operation, Export" > ${output_name}.csv
}
function xmlParser {

	count=$(xmllint --xpath 'count(//bean)' ${xml_name})
	banner "Total Number of Jobs Definition: ${count}"
	if [ ${count} -eq "0" ]; then
		banner "No Jobs Definition";
		exit -1;
	else 
		
		for (( i=1; i <= ${count}; i++ )); do 
			
			jobName=$(xmllint --xpath 'string(//bean['$i']/@id)' ${xml_name})
			jobEntity=$(xmllint --xpath 'string(//bean[@id="'${jobName}'"]//entry[@key="sfdc.entity"]/@value)' ${xml_name})
			jobOperation=$(xmllint --xpath 'string(//bean[@id="'${jobName}'"]//entry[@key="process.operation"]/@value)' ${xml_name})
			jobExport=$(xmllint --xpath 'string(//bean[@id="'${jobName}'"]//entry[@key="process.outputSuccess"]/@value)' ${xml_name})
			if [ $? -gt 0 ]; then
				echo error at $i
			fi
			echo "${i} , ${jobName} , ${jobEntity} , ${jobOperation} , ${jobExport}" >> ${output_name}.csv 
		done
	fi
}
setHeaders
xmlParser
