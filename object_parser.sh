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
	echo "Counter , field Name, Field Formula contains img tag ends with c" > ${output_name}.csv
}
function xmlParser {

	count=$(xmllint --xpath 'count(//fields)' ${xml_name})
	banner "Total Number of Fields Definition: ${count}"
	formula=$(xmllint --xpath 'count(//formula)' ${xml_name})
	banner "Total Number of formula Definition: ${formula}"
	if [ ${count} -eq "0" ]; then
		banner "No Jobs Definition";
		exit -1;
	else 
		
		for (( i=1; i <= ${count}; i++ )); do 
			
			fieldName=$(xmllint --xpath 'string(//fields['$i']/fullName)' ${xml_name})
			fieldFormula=$(xmllint --xpath 'normalize-space(string(//fields['$i']/formula[contains(text(),"img_")]))' ${xml_name})
			parseFormula=$(echo ${fieldFormula} | grep '__c')	
			
			if [ -z ${parseFormula} ]; then
				parseFormula="No Image field with __c found"
			fi

			echo "${i} , ${fieldName}, '${parseFormula}'" | tee -a  ${output_name}.csv 
		done
	fi
}
setHeaders
xmlParser
