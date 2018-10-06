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
               echo "Usage: -P <Path to XML File> -O <Output CSV Name> -T <Image field =1, Related Object =2>" 
               echo "++++++++++++++++"
}

function banner {
	echo "+++++++++++++++++++++++++++++"
	echo "${1}"
	echo "+++++++++++++++++++++++++++++"	
}
errorStatus=0

while getopts :P:O:T: FLAG
do
    case ${FLAG} in
    P) export xml_name=${OPTARG};;
    O) export output_name=${OPTARG};;
    T) export typeProccessing=${OPTARG};;
    *) show
       exit 1;;
    esac
done



if [[ -z ${xml_name} || -z ${output_name} || -z ${typeProccessing} ]]; then
      show
      exit
fi
function setHeaders {
	echo $1 > ${output_name}.csv
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
		$1
	fi
}

function fieldFormulaParser {
	for (( i=1; i <= ${count}; i++ )); do 
			
		fieldName=$(xmllint --xpath 'string(//fields['$i']/fullName)' ${xml_name})
		fieldFormula=$(xmllint --xpath 'normalize-space(string(//fields['$i']/formula[contains(text(),"img_")]))' ${xml_name})
		parseFormula=$(echo ${fieldFormula} | grep '__c')	
			
		if [ -z ${parseFormula} ]; then
			parseFormula="No Image field with __c found"
		fi
		echo "${i} , ${fieldName}, '${parseFormula}'" | tee -a  ${output_name}.csv 
	done
}

function objectFormulaParser {
	for (( i=1; i <= ${count}; i++ )); do 
			
		fieldName=$(xmllint --xpath 'string(//fields['$i']/fullName)' ${xml_name})
		relationshipName=$(xmllint --xpath 'normalize-space(string(//fields['$i']/relationshipName))' ${xml_name})
		referenceTo=$(xmllint --xpath 'string(//fields['$i']/referenceTo)' ${xml_name})
		type=$(xmllint --xpath 'string(//fields['$i']/type)' ${xml_name})
			
		if [ -z ${relationshipName} ]; then
			relationshipName="No Relationship"
		fi
					
		if [ -z ${referenceTo} ]; then
			referenceTo="No reference"
		fi
		if [ -z ${type} ]; then
			type="No type"
		fi

		echo "${i} , ${fieldName}, '${relationshipName}', '${referenceTo}', '${type}'" | tee -a  ${output_name}.csv 
	done
}
if [ ${typeProccessing} == "1" ]; then
	setHeaders "Counter , field Name, Field Formula contains img tag ends with c"
	xmlParser fieldFormulaParser
elif [ ${typeProccessing} == "2" ]; then
	setHeaders "Counter , field Name, relationshipName, referenceTo, type"
	xmlParser objectFormulaParser
fi
