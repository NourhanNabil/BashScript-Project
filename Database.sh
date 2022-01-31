#!/bin/bash
# Functions
createTable(){
    echo "enter name of the table"
    read tableName
    until [ ! -z $tableName ] 
                do  
                echo "Enter a table name"
                read tableName 
                done  
    echo "the number of Meta-data columns"
    read noColumns
        until [ ! -z $noColumns ] 
          do  
          echo "Enter a value, no null values accepted"
          read noColumns 
          done  
          until [[ $noColumns =~ [0-9] ]] 
          do  
          echo "Enter numbers only"
          read noColumns 
          done  
        fieldSeparator=":" 
      for i in $(seq $noColumns)
        do 
          if [ $i -eq 1 ]
            then
              echo "Enter the primary key of column $i"
              read columnName
                until [ ! -z $columnName ] 
                  do  
                  echo "This is a primary key name, it can not be null"
                  read columnName 
                  done  
                  until [[ $columnName =~ [a-zA-Z] ]]
                  do  
                  echo "This is a primary key name, it must start with charachters"
                  read columnName 
                  done 
              primaryKey=$columnName 
              firstRecord=$columnName$fieldSeparator
            else
              echo "Enter the column number $i"
              read columnName
              until [ ! -z $columnName ] 
                  do  
                  echo "Enter a value, no null values accepted"
                  read columnName 
                  done  
                if [ $i = $noColumns ]
                  then 
                    firstRecord=$firstRecord$columnName
                  else
                    firstRecord=$firstRecord$columnName$fieldSeparator
                fi                                  
          fi 
        done 
#Menu for selection of the table format
    echo "Choose the desired format for the table"
select choice in "XML format" "CVS format" "JSON format" "Other format"
  do 
    case $choice in 
      "XML format" )
        until [[ "./$tableName.xml" != "`find -type f -name $tableName.xml 2>>/dev/null`" && ! -z $tableName ]]
        do 
            echo "This table already exists, enter another table name"
            read tableName
        done 
          touch $tableName.xml
          echo $firstRecord > $tableName.xml   
          echo "Table $tableName.xml created successfully "  
            firstRecord=""  
            ConnectMenu ;;
      "CVS format" ) 
        until [[ "./$tableName.cvs" != "`find -type f -name $tableName.cvs 2>>/dev/null`" && ! -z $tableName ]]
          do 
              echo "This table already exists, enter another table name"
              read tableName
          done       
        touch $tableName.csv
        echo $firstRecord > $tableName.csv    
        echo "Table $tableName.csv created successfully " 
        firstRecord=""
        ConnectMenu ;;
      "JSON format" ) 
        until [[ "./$tableName.json" != "`find -type f -name $tableName.json 2>>/dev/null`" && ! -z $tableName ]]
          do 
              echo "This table already exists, enter another table name"
              read tableName
          done           
        touch $tableName.json
        echo $firstRecord > $tableName.json    
        echo "Table $tableName.json created successfully " 
        firstRecord=""
        ConnectMenu ;; 
      "Other format" )
        echo "enter the name of the format for the table"
        read format 
        until [[ "./$tableName.$format" != "`find -type f -name $tableName.$format 2>>/dev/null`" && ! -z $format ]]
          do 
              echo "This table already exists, enter another table name"
              read tableName
          done            
        touch $tableName.$format
        echo $firstRecord > $tableName.$format    
        echo "Table $tableName.$format created successfully " 
        firstRecord=""
        ConnectMenu ;;
      * ) echo $REPLY is not one of the choices ;;    
    esac
  done                        
    
  }  
listTables(){
      listTables=`ls -Al |grep ^- | wc -l`
      if [ $listTables -eq 0 ] 
        then 
          echo "No Tables to be listed"
        else 
           ls -p | grep -v / 
      fi
        } 
DropTable(){
    echo "Enter the name of table to be dropped with its format"  
    read nameoftable
  if [ "./$nameoftable" = "`find -type f -name $nameoftable 2>>/dev/null`" ] 
    then 
      rm $nameoftable;
      echo "$nameoftable is dropped successfully";
    else
      echo "This table does not exist"
  fi 
  } 
insertIntoTable(){
    echo "Enter the name of table with its format"
    read nameOfTable
    separator=":"  
    if [ "./$nameOfTable" = "`find -type f -name $nameOfTable 2>>/dev/null`" ]
      then
        fields=`awk -F : 'NR==1{print NF}' $nameOfTable`
        for i in $(seq $fields)
        do
        fieldName=`awk -F : 'NR==1{print $'$i'}' $nameOfTable`
          if [ $i -eq 1 ]
            then
              echo "Enter the value of $fieldName Field"
              read value
                until [[ ! -z $value &&  "$value" != "`awk -F ":" '{NF=1; print $'$i'}' $nameOfTable | grep "$value"`" ]]  
                 do  
                  echo "This is a primary key can not be null or already exists"
                  read value 
                 done  
                  Row=$value$separator
            else
            echo "Enter the value $fieldName Field"
            read value
             until [ ! -z $value ] 
                 do  
                  echo "Enter a value, no null values accepted"
                  read value 
                 done  
            if [ $i = $fields ]
              then 
               Row=$Row$value
              else
               Row=$Row$value$separator
            fi                                  
          fi 
        done
          echo $Row >> $nameOfTable    
          echo "Row successfully inserted into $nameOfTable"  
          Row=""
          ConnectMenu
      else
          echo "This table does not exist"
          echo "take into consideration the case sensitivity and the file format" 
    fi
  }
exitScript(){
  echo "You ended the bash script"
  exit
 }
selectFromTable(){
 echo "Enter the name of table you want to select from"
 read tableToSelectFrom
              until [ ! -z $tableToSelectFrom ] 
              do  
              echo "Enter name of the table"
              read tableToSelectFrom 
              done  
   if [ "./$tableToSelectFrom" = "`find -type f -name $tableToSelectFrom 2>>/dev/null`" ]
    then
    select choice in "Select all from table" "Select specific record from table" "previous menu"
       do
        case $choice in 
            "Select all from table" )
              echo -e "`sed  "/*/p" $tableToSelectFrom`"  
                 ;;
            "Select specific record from table" ) 
                echo "Enter the value you want to select from $tableToSelectFrom "
                read value
                 until [ ! -z $value ]  
                    do  
                    echo "Enter the value you want to select from $tableToSelectFrom "
                    read value 
                    done  
                 if [ "$value" = "`awk -F : '{print $1 }' $tableToSelectFrom | grep "\b$value\b" `" ]
                  then
                  NR=`awk -F ":" '{if($1=="'$value'") print NR}' $tableToSelectFrom `
                  echo `sed -n ""$NR"p" $tableToSelectFrom`
                   else
                    echo "This value not found in $tableToSelectFrom "
                 fi
                    ;;
            "previous menu" )
                    ConnectMenu  ;;
            * ) echo $REPLY is not one of the choices ;;
        esac
       done 
        
    else
    echo "This Table does not exist"
    echo "take into consideration the case sensitivity and the file format"
   fi 
 }
deleteFromTable(){
 echo "Enter name of the table to delete from "
 read tableToDeleteFrom
    if [ "./$tableToDeleteFrom" = "`find -type f -name $tableToDeleteFrom 2>>/dev/null`"  ]
     then
      echo "enter the value of primary key to delete its row"
      read primarykeyValue
                until [ ! -z $primarykeyValue ]
                do
                  echo "No null values in primary key field"
                  read primarykeyValue
                done 
            if [ "$primarykeyValue" = "`awk -F ":" '{NF=1; print $1}' $tableToDeleteFrom | grep "\b$primarykeyValue\b"`" ]
              then
                NR=`awk -F ":" '{if($1=="'$primarykeyValue'") print NR}' $tableToDeleteFrom `
                 `sed -i ''$NR'd' $tableToDeleteFrom` 
                echo "The row of primary key value $primarykeyValue deleted successfully "
              else 
                echo "This primary key value does not exist"
            fi     
     else
      echo "This table does not exist"
      echo "take into consideration the case sensitivity and the file format"
    fi 
 }
# Connect to Main menu 
MainMenu(){
  echo -e "##Note This Script is case sensitive
##Enter only the number referring to the desired choice
------Main Menu------"
  select choice in "Create Database" "List Databases" "Connect To Databases" "Drop Database" "Exit"
  do
    case $choice in
      "Create Database" ) 
        Create(){
          echo "enter name of the database"
          read dbname
           until [ ! -z $dbname ] 
                do  
                echo "Enter a database name"
                read dbname 
                done  
            until [[ $dbname =~ ^[a-zA-Z0-9]*$ ]] 
              do  
              echo "Do not use special characters"
              read dbname 
              done  
            if [ "./$dbname" = "`find -name $dbname 2>>/dev/null`" ]
              then
                echo "This database already exists"
              else
                mkdir $dbname
                echo "$dbname created successfully"
            fi
        } 
      Create ;; #Call the Create function
      "List Databases" )
        listDatabases(){
          listdb=`ls -Al |grep ^d | wc -l`
            if [ $listdb -eq 0 ] 
              then 
                echo "No databases to be listed"
              else 
                ls  -d */  | awk -F'/' '{print $1}'
            fi
        } 
      listDatabases ;; #Call the listDatabases function
      "Connect To Databases" ) 
        echo "Enter the name of database";
        read input ;
        if [ "./$input" = "`find -name $input 2>>/dev/null`" ]
          then
              cd $input;
              echo "You are now connected to $input Database"
              ConnectMenu #Call the ConnectMenu function     
          else 
              echo "This database does not exist";
        fi ;; 
      "Drop Database" ) 
        Dropdb(){ 
          echo "Enter the name of database to be dropped"  
          read dbToBeDropped 
          if [ "./$dbToBeDropped" = "`find -name $dbToBeDropped 2>>/dev/null`" ]
            then 
              echo "Enter Yes/No to confirm if you want to delete $dbToBeDropped"
              read answer
                until [ ! -z $answer ] 
                  do  
                  echo "Enter a confirmation with either yes or no "
                  read answer 
                  done  
              if [ $answer = Yes -o $answer = yes -o $answer = y -o $answer = Y  ]
                then
                  rm -r $dbToBeDropped
                  echo "$dbToBeDropped dropped successfully"
                else
                  echo "$dbToBeDropped did not drop"
              fi
            else
                echo "This database does not exist"
          fi 
        }
      Dropdb ;; #Call the Dropdb function
      "Exit" ) 
      exitScript;; #Call the exitScript function  
      * ) echo $REPLY is not one of the choices ;;      
    esac
  done
}
PreviousMenu(){
   cd .. ; MainMenu
 }
# Connect to Databases menu
ConnectMenu(){
      select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Previous menu" "Exit"
      do 
        case $choice in 
            "Create Table" )
            createTable ;; #Call the createTable function
            "List Tables" ) 
            listTables ;;  #Call the listTables function 
            "Drop Table" ) 
            DropTable  ;; #Call the DropTable function 
            "Insert into Table" ) 
            insertIntoTable ;; #Call the insertIntoTable function 
            "Select From Table" ) 
            selectFromTable ;; #Call the selectFromTable function
            "Delete From Table" ) 
            deleteFromTable ;; #Call the deleteFromTable function
            "Previous menu" ) 
            PreviousMenu;; #Call the PreviousMenu function
            "Exit" ) 
            exitScript;; #Call the exitScript function 
            * ) echo $REPLY is not one of the choices ;;
        esac
      done
} 
cd Databases #start the script in the Databases Directory
MainMenu #Call the MainMenu function