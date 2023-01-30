#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointments ~~~~~\n"

echo -e "\nHere are the services we have available."
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

SERVICES(){
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
}

SERVICES

echo -e "\nWhich service would you like to book today?"
read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  SERVICES "Please pick a valid service number"
else
  echo -e "\nPlease enter your phone number"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  echo -e "\nHello $CUSTOMER_NAME\nWhat time would you like to book your appointment for? Please format it like <hh:mm>"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  APPOINTMENT_INFO_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  echo -e "\nI have put you down for a $APPOINTMENT_INFO_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
