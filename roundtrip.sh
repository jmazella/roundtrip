#!/bin/bash          
echo Executing Round Trip 
echo clearing tmp folder..
rm -rf tmp/*
cd tmp

#clone cypress
git clone https://github.com/projectcypress/cypress.git
cd cypress
git checkout develop
bundle install

#export patient zip, unzip it
export DB_NAME=cypress_test
rake round_trip:export_zip[../patients_c32.zip]
unzip -d ../patients_c32 ../patients_c32.zip

#clone pophealth
cd ..
git clone https://github.com/pophealth/popHealth.git
cd popHealth
git checkout develop
bundle install

#clone measures
cd ..
git clone https://github.com/pophealth/measures.git
cd measures
git checkout develop
bundle install
export DB_NAME=pophealth-development
bundle exec rake mongo:reload_bundle

#generate PQRI
cd ../popHealth
bundle exec rake import:patients[../patients_c32/,true]
#bundle exec rake pqri:report[1293670800] #12/30
bundle exec rake pqri:report[1293584400] #12/29
#bundle exec rake pqri:report[1293757200] #12/31

#check PQRI
cd ../cypress
export DB_NAME=cypress_test
rake round_trip:check_pqri[../measures,../popHealth/tmp/pophealth_pqri.xml]
