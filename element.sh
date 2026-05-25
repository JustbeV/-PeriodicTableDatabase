#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT=$1

# query: match atomic_number OR symbol OR name
RESULT=$($PSQL "
SELECT
  e.atomic_number,
  e.name,
  e.symbol,
  p.atomic_mass,
  p.melting_point_celsius,
  p.boiling_point_celsius,
  t.type
FROM elements e
JOIN properties p USING(atomic_number)
JOIN types t USING(type_id)
WHERE
  e.atomic_number::text = '$INPUT'
  OR e.symbol ILIKE '$INPUT'
  OR e.name ILIKE '$INPUT';
")

if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

echo "$RESULT" | while IFS="|" read ATOMIC NAME SYMBOL MASS MELTING BOILING TYPE
do
  echo "The element with atomic number $ATOMIC is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
done