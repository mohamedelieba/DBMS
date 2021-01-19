#!/usr/bin/bash
####*******************************************####
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
mkdir $DIR/DB 2>> /dev/null

function Create {
echo -e "${YELLOW}Enter your DataBase name${NC}:\n"
read 

	mkdir $DIR/DB/$REPLY 2>> /dev/null
	if [ $? = 0 ]
	then
		echo -e "${GREEN}your $REPLY DataBase added successfully${NC}\n"
	else
		echo -e "${RED} $REPLY DataBase already exists${NC}\n"
	fi
	mainMenu	
}
function List {

dir="$DIR/DB/"

if [ "$(ls -A $dir)" ]
then
	echo -e "${YELLOW} your DataBase(s) are: "
     ls -a $dir
else

    echo -e "\n\n${BLUE}Your DataBase is Empty${NC}\n"
fi
	mainMenu
}


function Connect {
	echo -e "${YELLOW}Enter the name of the DataBse you want to connect to:${NC}\n"
	read
	cd $DIR/DB/$REPLY 2>> /dev/null 
	if [ $? = 0 ]
	then
		tablesMenu
	else
		echo -e "${RED}No DataBase with such Name $REPLY${NC}\n"
		mainMenu
	fi
	}

	function tablesMenu {
	echo -e "\n*********************************************************\n"
	select option in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select from table" "Delete From Table" "Back to Main Menu"
	do
		case $REPLY in 
			1 ) clear
				createTable 
				;;
			2 ) clear
				listTables
				;;
			3 ) clear
				dropTable
				;;
			4 ) clear
				insert
				;;
		       	5 ) clear
				Select
				;;
			6 ) clear
				Delete
				;;
			7 ) clear
				mainMenu
				;;
			* ) echo -e "${RED}wrong entry${NC}\n"
		esac
	done
	
        #tablesMenu
}

function Drop {
	echo -e "${YELLOW}Enter the DataBase name that you want to drop${NC}\n"
	read
	rm -r $DIR/DB/$REPLY 2>> /dev/null
	if [ $? = 0 ]
        then
                echo -e "${GREEN}your $REPLY DataBase Dropped successfully${NC}\n"
        else
                echo -e "${RED}There's no DataBase $REPLY to drop${NC}\n"
        fi
	mainMenu
}
#########********************************************************#############
typeset -i columnNumber
function createTable {
	mkdir tables 2>> /dev/null
	mkdir metaData 2>> /dev/null

	echo -e "${YELLOW}Enter a name of your Table${NC}\n"
	read tableName
	if [ -f tables/$tableName.csv ]

	then 
		echo -e "${RED} $tableName Table already exists${NC}\n"
	else

	echo -e "${YELLOW}Enter the number of your $tableName Columns${NC}\n"
	read columnNumber
	echo -e "${YELLOW}Enter names of your $tableName Table Fields${NC}\n"
	fields=()
	#typeset -i columnNumber	
	typeset -i i=1
	while ((i <= columnNumber))
	do 
		echo -e "${YELLOW}Enter field number $i ${NC}\n"
		read field 
	fields[$i]=$field
		i=i+1
	done
	printf -v joined '%s,' "${fields[@]}"
	echo "${joined%,}" >> tables/$tableName.csv
	printf "table Name:$tableName\ncolumn Number:$columnNumber\ntable Columns:${fields[*]}\npk:${fields[1]}" >> metaData/$tableName.metaData
fi

	tablesMenu	
}
function listTables {
			 echo -e "\n-----------------------------------------------------------------\n"
	
		         ls -a tables 2>> /dev/null

		 	 if [ $? = 0 ]
                       		 then
				  echo -e "\n-----------------------------------------------------------------\n"

                                  else

                                   echo -e "${BLUE}this DataBase is currently empty${NC}\n"
                          fi

                      

		tablesMenu
}
function dropTable {
	echo -e "${YELLOW}Enter Table Name to Drop${NC}\n"
	read 
	rm -r tables/$REPLY.csv 2>> /dev/null
	rm -r metaData/$REPLY.metaData 2>> /dev/null
	if [ $? = 0 ]
	then
		echo -e "${GREEN} $REPLY Table dropped successfully${NC}\n"
		tablesMenu
	else
		echo -e "${RED}No table with such Name $REPLY${NC}\n"
		tablesMenu
	fi
	
}

function insert {
	echo -e "${YELLOW}which table you want to insert into${NC}\n"
	read tableName
	if [ -f "tables/$tableName.csv" ]
	then
	data=()
        typeset -i i=1
	columnNumber=$(awk -F: '{if(NR==2) print $2}' metaData/$tableName.metaData)

        while ((i <= columnNumber))
        do

	echo -e "${YELLOW}enter `awk -F"," -v var="$i" '{if(NR==1) print $var}' tables/$tableName.csv`${NC}\n"
                read field
        data[$i]=$field
	if [ -z ${data[1]} ]
	then
		echo -e "${RED}primary key value can not be null${NC}\n"
	
	elif cut -f1 -d"," tables/$tableName.csv | grep -q -x "${data[1]}"
	then 
	echo -e "${RED}primary key must be unique${NC}\n"
else

                i=i+1
	fi
        done
	printf -v joined '%s,' "${data[@]}"
        echo "${joined%,}" >> tables/$tableName.csv
else
	echo -e "${RED}No such table $tableName in your DataBase${NC}\n"
        fi
	tablesMenu
}

function Select {
	echo -e "${YELLOW}which table do you want to select from${NC}\n"
	read tableName
	if [ -f "tables/$tableName.csv" ]
	then
	select option in "show all data" "select a specific row"
	do
		case $REPLY in 
			1 ) echo -e "\n******************************************\n"
				echo -e "${YELLOW}your retreived data is:${NC}\n"
				cat tables/$tableName.csv
			    echo -e "\n******************************************\n" 
				break
				;;
			2 ) echo -e "${YELLOW}Enter $(awk -F: '{if(NR==4) print $2}' metaData/$tableName.metaData)${NC}\n"
				read pk
			
				echo -e "\n**************************************\n"	
				data=$(grep -c $pk tables/$tableName.csv)
				if [ $data -eq 0 ]
				then
					echo -e "${RED}Not Found${NC}\n"
				else
				#grep $pk tables/$tableName.csv
				echo -e "${YELLOW}your data is:\n\n${BLUE}`awk -F"," '{if(NR==1) print $0}' tables/$tableName.csv`${NC}\n"
 				echo -e "${BLUE}`awk -F"," -v var="$pk" '{if(var==$1) print $0}' tables/$tableName.csv`${NC}\n"

				#awk -F"," -v var="$pk" '{if($var==$1) print $0}' tables/$tableName.csv

				fi
				echo -e "\n**************************************\n"
				break
				;;
			* ) echo -e "${RED}wrong entry${NC}\n"
		esac

	done
else
echo -e "${RED}No such table whith that name${NC}\n"
fi
  tablesMenu     
}
function Delete {
	echo -e "${YELLOW}Enter the name of the table:${NC}\n"
	read tableName
	if [ -f "tables/$tableName.csv" ]
	then
	echo -e "${YELLOW}Enter $(awk -F: '{if(NR==4) print $2}' metaData/$tableName.metaData)${NC}\n"

	read pk
	if cut -f1 -d"," tables/$tableName.csv | grep -q -x "$pk"
                                then
                                      #echo -e "${RED}NOT Found${NC}\n"
				       sed -i "/^$pk\b/Id" tables/$tableName.csv

				      echo -e "${GREEN} your data deleted successfully${NC}\n"
                                else
  				echo -e "${RED}NOT Found${NC}\n"	 
                                fi
			else
				echo -e "${RED}No such table in your DataBase${NC}\n"
			fi
				tablesMenu	
}

########**************************************#########
RED='\033[0;31m'
NC='\033[0m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
function mainMenu {
echo -e "\n***********************************************************************\n"

select option in "press 1 to create a DataBase" "press 2 to list DataBases" "press 3 to connect to a DataBase" "press 4 to Drop a DataBase" "press 5 to Exit"
do
	case $REPLY in
		1 ) clear
			Create	
			;;
		2 ) clear
		       	List
			;;
		3 ) clear
			Connect
			;;
		4 ) clear
			Drop
			;;
		5 ) exit
			;;
		* ) echo -e "${RED} Wrong Entry${NC}\n"
	esac
done
}

mainMenu
