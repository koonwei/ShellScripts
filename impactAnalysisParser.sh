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
               echo "Usage: -P <Path to Report Analysis> -O <Output CSV Name>" 
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
	echo $1 > ${output_name}.csv
}
function setBody {
	echo "${1}" | tee -a ${output_name}.csv
}
function dynamicParser {
	totalCount=$(grep -ci ${1}/ ${xml_name})
	banner "Total Number of ${1} ${totalCount}"
	parseData=$(grep -i ${1}/ ${xml_name})
        COUNTER=0	
	while read -r line; do
		let COUNTER=COUNTER+1 
		setBody "${COUNTER} ,Apex${1}, $(echo ${line})"
	done <<< "${parseData}"

}

setHeaders "Component Type, Component Name, Component Type"
declare -a arrayList=(classes Pages Components Flows Dashboards Reports)
for i in "${arrayList[@]}"
	do
		dynamicParser $i
	done
