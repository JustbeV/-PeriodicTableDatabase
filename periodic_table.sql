 
-- 1. CLEAN UP BAD DATA


DELETE FROM properties WHERE atomic_number = 1000;
DELETE FROM elements WHERE atomic_number = 1000;

 
-- 2. FIX COLUMN NAMES
 

ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;

ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;

ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

 
-- 3. CONSTRAINTS
 

ALTER TABLE properties
ALTER COLUMN melting_point_celsius SET NOT NULL;

ALTER TABLE properties
ALTER COLUMN boiling_point_celsius SET NOT NULL;

ALTER TABLE elements
ADD CONSTRAINT unique_symbol UNIQUE (symbol);

ALTER TABLE elements
ADD CONSTRAINT unique_name UNIQUE (name);

ALTER TABLE elements
ALTER COLUMN symbol SET NOT NULL;

ALTER TABLE elements
ALTER COLUMN name SET NOT NULL;

 
-- 4. FOREIGN KEY
 

ALTER TABLE properties
ADD CONSTRAINT fk_atomic_number
FOREIGN KEY (atomic_number)
REFERENCES elements (atomic_number);

 
-- 5. TYPES TABLE
 

CREATE TABLE types (
    type_id SERIAL PRIMARY KEY,
    type VARCHAR NOT NULL
);

INSERT INTO types (type)
VALUES ('metal'), ('nonmetal'), ('metalloid');

 
-- 6. LINK TYPE TO PROPERTIES
 

ALTER TABLE properties ADD COLUMN type_id INT;

UPDATE properties
SET type_id = types.type_id
FROM types
WHERE properties.type = types.type;

ALTER TABLE properties
ALTER COLUMN type_id SET NOT NULL;

ALTER TABLE properties
ADD CONSTRAINT fk_type
FOREIGN KEY (type_id)
REFERENCES types (type_id);

-- remove old type column
ALTER TABLE properties DROP COLUMN type;

 
-- 7. CLEAN SYMBOL CASE
 

UPDATE elements
SET symbol = UPPER(LEFT(symbol, 1)) || LOWER(SUBSTRING(symbol FROM 2));

 
-- 8. FIX ATOMIC MASS TYPE
 

ALTER TABLE properties
ALTER COLUMN atomic_mass TYPE NUMERIC;

 
-- 9. ADD MISSING ELEMENTS
 

INSERT INTO elements (atomic_number, name, symbol)
VALUES
(9, 'Fluorine', 'F'),
(10, 'Neon', 'Ne');

INSERT INTO properties (
    atomic_number,
    atomic_mass,
    melting_point_celsius,
    boiling_point_celsius,
    type_id
)
VALUES
(9, 18.998, -220, -188.1, (SELECT type_id FROM types WHERE type='nonmetal')),
(10, 20.18, -248.6, -246.1, (SELECT type_id FROM types WHERE type='nonmetal'));