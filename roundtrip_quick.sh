#!/bin/bash          
echo Executing Quick Round Trip 
cd tmp
#generate PQRI
cd popHealth
bundle exec rake import:patients[../patients_c32/,true]
bundle exec rake pqri:report[1293670800]
cd ../cypress
export DB_NAME=cypress_test
rake round_trip:check_pqri[../measures,../popHealth/tmp/pophealth_pqri.xml]
