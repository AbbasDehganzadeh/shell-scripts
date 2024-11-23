#! /usr/bin/bash

# Contact List Program
 # It has a full functionality to `Add`, `list`, 'search', `update`, and `delete` a person from contact
 # ID  name   mobilephone   address   email
 # Int Char   Number? <->   CHAR?     Email?
 # I hope you enjoy this.
#

# set up the contact list database
DATABASE="contact.sqlite"
CREATE_QUERY="CREATE TABLE IF NOT EXISTS tbcontact (ID INT PRIMARY KEY, name VARCHAR(50) UNIQUE NOT NULL, email VARCHAR(50) UNIQUE NOT NULL, phone VArchar(15), address VARCHAR(75), deleted BOOLEAN DEFAULt false  );"
# make sure the database is installed
if ! sqlite3 --version &> /dev/null
then
  echo 'sqlite does not exist'
  echo 'please install it first'
  exit 2;
fi
# check whether the database exists
echo $CREATE_QUERY | sqlite3 $DATABASE  

listaction='"1) Add Item" "2) List Item" "3) Search Item" "4) Update Item" "5) Delete Item" "6) Clear Screen" "7) Exit program"'
PS3="  Enter the Action, Please."


addItem() {
  ROWID_QUERY="SELECT MAX(ID) FROM tbcontact;"
  INSERT_QUERY="INSERT INTO tbcontact (name, phone, address, email) VALUES "
  rowid=`echo "$ROWID_QUERY" | sqlite3 $DATABASE `
  quit=false
  while [ $quit == "false" ]
  do
    read -p "name:  " name
    read -p "phone:  " phone
    read -p "address:  " address
    read -p "email:  " email

    # validate the input
    datavalidated=true;dataduplicated=false
    validatedata;duplicatedata

    if [ $datavalidated == "true" ] && [ $dataduplicated != "true" ]
    then
      INSERT_QUERY="$INSERT_QUERY ('$name' , '$phone' , '$address' , '$email') , ";
      sleep 1
    fi
    read -p "do you want to quit:(yes|no)  " answer
    if [ ${answer,,} == "yes" ]
    then
      INSERT_QUERY="${INSERT_QUERY::${#INSERT_QUERY}-3};" 
      echo $INSERT_QUERY | sqlite3 $DATABASE
      quit=true
      sleep 2
    fi

  done
  newrowid=`echo "$ROWID_QUERY" | sqlite3 $DATABASE `
  echo "$newrowid - $rowid"
  echo `expr $newrowid - $rowid`
  #python3 -c "print($newrowid - $rowid data inserted successfully.)"

}

listitem () {
  count=`echo "SELECT COUNT(*) FROM tbcontact WHERE deleted = false;" | sqlite3 $DATABASE`
  if [ $count == "0" ];then
    echo "list is empty;"
    return
  fi
  SELECT_QUERY="SELECT name, phone, address, email FROM tbcontact WHERE deleted = false";
  echo "list of items:"
  # TODO: format output in a concise way
  echo $SELECT_QUERY | sqlite3 $DATABASE

}


searchitem () {
  input=""
  fields="name phone address email"
  echo -e "choose a field to search"
  while true ;do
  echo "$fields"
  read input
  read -p "$input: " data
  if [[ $fields =~ (^|[[:space:]])$input($|[[:space:]]) ]]; then break; fi;
  echo -e "enter the valid field please"
  done

  SEARCH_QUERY="SELECT name, phone, address, email FROM tbcontact WHERE deleted = false AND $input LIKE '%$data%'; "
  search_result=`echo $SEARCH_QUERY | sqlite3 $DATABASE`
  if [ "$search_result" == "" ];then #empty list
    echo "No data found!"
  else
  # TODO: format output in a concise way
    echo " $search_result"
  fi

}


updateitem () {
  echo "search in name, phone, address, or email"
  read word
  SEARCH_QUERY="SELECT name, phone, address, email FROM tbcontact WHERE deleted = false AND (name LIKE '$word' OR phone LIKE '$word' OR address LIKE '$word' OR email LIKE '$word' );"
  search_result=`echo $SEARCH_QUERY | sqlite3 $DATABASE`
  if [ "$search_result" == "" ];then #no item
    echo "Nothing to update!"
    return
  fi
  #TODO: update each field properly, chosse default in case of empty
  i=0;items=()
  for item in $search_result
  do
    i=`expr $i + 1`
    echo "$i) $item"
    items+=(`echo "$item" | cut -d '|' -f 1`)
  done
  if [ "$i" -eq 1 ]; then
    num=1
  elif [ "$i" -ge 2 ]; then
    read -p "choose a number. [1:$i] " num
  else
    echo "no item to update!"
    return
  fi

  read -p "name:  " name
  read -p "phone:  " phone
  read -p "address:  " address
  read -p "email:  " email

  num=`expr $num - 1`
  UPDATE_QUERY="UPDATE tbcontact SET name='$name', phone='$phone', address='$address', email='$email' WHERE name='${items[$num]}'"
  # validate the input
  datavalidated=true;dataduplicated=false
  #validatedata;duplicatedata

  if [ $datavalidated == "true" ] && [ $dataduplicated != "true" ]
  then
    echo $UPDATE_QUERY | sqlite3 $DATABASE
    echo $UPDATE_QUERY
    sleep 2
    echo "data updated successfully."
  fi

}


deleteitem () {
  read -p "enter a name or phone: " input
  search_result=`echo "SELECT name, phone, address, email FROM tbcontact WHERE name LIKE '$input' OR phone LIKE '$input'" | sqlite3 $DATABASE`
  i=0;items=()
  for item in $search_result
  do
    i=`expr $i + 1`
    echo "$i) $item"
    items+=(`echo "$item" | cut -d '|' -f 1`)
  done
  if [ "$i" -eq 1 ]; then
    num=1
  elif [ "$i" -ge 2 ]; then
    read -p "choose a number. [1:$i] " num
  else
    echo "no item to delete!"
    return
  fi

  num=`expr $num - 1`
  DELETE_QUERY="DELETE FROM tbcontact WhERE deleted = false AND name = '${items[$num]}'"
  if [ -n "$num" ] && [ $num -ge 0 ] && [ $num -lt $i ]; then
    read -p "Are you sure[n,y]?:" s
  else
    echo "Wrong input [$num],"
    return
  fi
  confirm="${s:=no}"
  # inform the user for deleting;
  if [ ${confirm:0:1} == "y" ]; then
    echo $DELETE_QUERY | sqlite3 $DATABASE
    sleep 2
    echo "data deleted successfully."
  else
    echo "data is not deleted!"
  fi
  
}


validatedata () {
  echo -e ''

}


duplicatedata() {
  echo -e ''

}


	echo -e "Contact Program.\n"
select choice in 'Add Item' 'List Item' 'Search Item' 'Update Item' 'Delete Item' 'Clear Screen' 'Exit program'
do
case $REPLY in
  1)
    addItem
    ;;
  2)
    listitem
    ;;
  3)
    searchitem;
    ;;
  4)
    updateitem;
    ;;
  5)
    deleteitem;
    ;;
  6)
    clear -x
    echo "$listaction"
    ;;
  7)
    echo 'exit program'
    exit 1
    ;;
  *)
    echo 'Wrong Input, Please try again.';
    ;;
esac
done
