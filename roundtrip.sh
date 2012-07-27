#!/bin/bash          

clearTmp(){
  echo clearing tmp folder..
  rm -rf tmp/*
  cd tmp
}

cloneCypress(){
  echo -----Begin clone Cypress---------
  git clone https://github.com/projectcypress/cypress.git
  cd cypress
  git checkout develop
  bundle install

  #export patient zip, unzip it
  export DB_NAME=cypress_development
  echo $DB_NAME
  cp -r ../../json/ db/master_patient_list/
  bundle exec rake mpl:install
  bundle exec rake mpl:create_populations
  bundle exec rake test:round_trip:export_zip[../patients_c32.zip]
  unzip -d ../patients_c32 ../patients_c32.zip
  cd ..
  echo -----End clone Cypress---------
}

clonePopHealth(){
  echo -----Begin clone Pophealth---------
  git clone https://github.com/pophealth/popHealth.git
  cd popHealth
  git checkout develop
  bundle update
  cd ..
  echo -----End clone Pophealth---------
}

cloneMeasures(){
  echo -----Begin clone Measures---------
  git clone https://github.com/pophealth/measures.git
  cd measures
  git checkout develop
  bundle install
  export DB_NAME=pophealth-development
  bundle exec rake mongo:reload_bundle
  export DB_NAME=cypress_development
  bundle exec rake mongo:reload_bundle
  cd ..
  echo -----End clone Measures--------
}

generatePQRI(){
  echo -----Begin generate PQRI---------
  cd popHealth
  export DB_NAME=pophealth-development
  bundle exec rake import:patients[../patients_c32/,true] --trace
  bundle exec rake pqri:report[1293670800] #12/30
  #bundle exec rake pqri:report[1293584400] #12/29
  #bundle exec rake pqri:report[1293757200] #12/31
  cd ..
  echo -----End generate PQRI ---------
}

validatePQRI(){
  echo -----Begin Validate PQRI---------
  cd cypress
  export DB_NAME=cypress_development
  echo $DB_NAME
  bundle exec rake test:round_trip:check_pqri[../measures,../popHealth/tmp/pophealth_pqri.xml]
  cd ..
  echo -----End Validate PQRI ---------
}

fullRoundtrip(){
 clearTmp
 cloneCypress
 clonePopHealth
 cloneMeasures
 generatePQRI
 validatePQRI
}

quickRoundtrip(){
 cd tmp
 generatePQRI
 validatePQRI
}

if [ $# -eq 1 ]
then
  echo Executing Quick Round Trip
  quickRoundtrip
else
  echo Executing Full Round Trip
  fullRoundtrip
fi
