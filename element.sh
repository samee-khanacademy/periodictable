#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  CONDITION="e.atomic_number = $1"
else
  # Escape any single quotes before placing text in an SQL literal.
  INPUT=${1//\'/\'\'}
  CONDITION="e.symbol = '$INPUT' OR e.name = '$INPUT'"
fi

ELEMENT_DATA=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p USING(atomic_number) JOIN types t USING(type_id) WHERE $CONDITION")

if [[ -z $ELEMENT_DATA ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$ELEMENT_DATA"

printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
  "$ATOMIC_NUMBER" "$NAME" "$SYMBOL" "$TYPE" "$ATOMIC_MASS" "$NAME" "$MELTING_POINT" "$BOILING_POINT"