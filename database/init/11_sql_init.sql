-- copy the data FAO forest 
DROP TABLE IF EXISTS fao_stats;
CREATE TABLE IF NOT EXISTS fao_stats(
   "Year" integer
  ,"Area" varchar
  ,"Country area" numeric
  ,"Forest land" numeric
  ,"Land area" numeric
  ,"Naturally regenerating forest" numeric
  ,"Planted Forest" numeric
  ,"Share of forests in Land area" numeric
  ,"Share of naturally regenerating forest" numeric
  ,"Share of planted forests" numeric
  ,"Carbon stock in Living Biomass" numeric
  ,"C02 removal from forest land" numeric
  ,"Net Forest conversion" numeric
  ,"Tree covered areas MODIS" numeric
);

COPY fao_stats("Year", "Area", "Country area", "Forest land", "Land area", "Naturally regenerating forest", "Planted Forest", "Share of forests in Land area", 
"Share of naturally regenerating forest", "Share of planted forests", "Carbon stock in Living Biomass", "C02 removal from forest land", "Net Forest conversion", 
"Tree covered areas MODIS")
FROM '/importdata/FAO_Forest.csv' WITH (FORMAT CSV, HEADER 1);

-- Calculate yearly change 
-- Add the columns to the table
ALTER TABLE fao_stats
ADD COLUMN yearly_change_area NUMERIC,
ADD COLUMN yearly_change_share NUMERIC;

-- Use a CTE to calculate the values
WITH changes_cte AS (
    SELECT 
        "Area",
        "Year",
        "Forest land",
        CASE 
            WHEN LAG("Forest land") OVER (PARTITION BY "Area" ORDER BY "Year") IS NULL THEN 0 
            ELSE "Forest land" - LAG("Forest land") OVER (PARTITION BY "Area" ORDER BY "Year") 
        END AS yearly_change_area,
        ROUND(
            CASE 
                WHEN LAG("Forest land") OVER (PARTITION BY "Area" ORDER BY "Year") IS NULL THEN 0 
                ELSE ("Forest land" - LAG("Forest land") OVER (PARTITION BY "Area" ORDER BY "Year")) / LAG("Forest land") OVER (PARTITION BY "Area" ORDER BY "Year") * 100 
            END,
            2
        ) AS yearly_change_share
    FROM 
        fao_stats
)
-- Update the table using the calculated values from the CTE
UPDATE fao_stats
SET 
    yearly_change_area = changes_cte.yearly_change_area,
    yearly_change_share = changes_cte.yearly_change_share
FROM changes_cte
WHERE 
    fao_stats."Area" = changes_cte."Area"
    AND fao_stats."Year" = changes_cte."Year";

-- Upload borders dataset
DROP TABLE IF EXISTS borders;
CREATE TABLE IF NOT EXISTS borders(
    "Geo Point" varchar
  ,"Geo Shape" geometry(geometry, 4326)
  ,"ISO 3 territory code" varchar
  ,"English Name" varchar
);

COPY borders("Geo Point", "Geo Shape", "ISO 3 territory code", "English Name")
FROM '/importdata/borders.csv' WITH (FORMAT CSV, HEADER 1);

-- ----------------------------------------------------------------------------------------------
-- LOSSYEAR --
-- ----------------------------------------------------------------------------------------------
-- RENAMINE TABLES
alter table "lossyear_hansen_gfc_lossyear_10n_080w.tif" rename to lossyear_hansen_gfc_10n_080w;
alter table "lossyear_hansen_gfc_lossyear_10n_070w.tif" rename to lossyear_hansen_gfc_10n_070w;
alter table "lossyear_hansen_gfc_lossyear_10n_060w.tif" rename to lossyear_hansen_gfc_10n_060w;
alter table "lossyear_hansen_gfc_lossyear_00n_080w.tif" rename to lossyear_hansen_gfc_00n_080w;
alter table "lossyear_hansen_gfc_lossyear_00n_070w.tif" rename to lossyear_hansen_gfc_00n_070w;
alter table "lossyear_hansen_gfc_lossyear_00n_060w.tif" rename to lossyear_hansen_gfc_00n_060w;
alter table "lossyear_hansen_gfc_lossyear_00n_050w.tif" rename to lossyear_hansen_gfc_00n_050w;
alter table "lossyear_hansen_gfc_lossyear_10s_080w.tif" rename to lossyear_hansen_gfc_10s_080w;
alter table "lossyear_hansen_gfc_lossyear_10s_070w.tif" rename to lossyear_hansen_gfc_10s_070w;
alter table "lossyear_hansen_gfc_lossyear_10s_060w.tif" rename to lossyear_hansen_gfc_10s_060w;

alter table "o_128_lossyear_hansen_gfc_lossyear_10n_080w.tif" rename to o_128_lossyear_hansen_gfc_10n_080w;
alter table "o_128_lossyear_hansen_gfc_lossyear_10n_070w.tif" rename to o_128_lossyear_hansen_gfc_10n_070w;
alter table "o_128_lossyear_hansen_gfc_lossyear_10n_060w.tif" rename to o_128_lossyear_hansen_gfc_10n_060w;
alter table "o_128_lossyear_hansen_gfc_lossyear_00n_080w.tif" rename to o_128_lossyear_hansen_gfc_00n_080w;
alter table "o_128_lossyear_hansen_gfc_lossyear_00n_070w.tif" rename to o_128_lossyear_hansen_gfc_00n_070w;
alter table "o_128_lossyear_hansen_gfc_lossyear_00n_060w.tif" rename to o_128_lossyear_hansen_gfc_00n_060w;
alter table "o_128_lossyear_hansen_gfc_lossyear_00n_050w.tif" rename to o_128_lossyear_hansen_gfc_00n_050w;
alter table "o_128_lossyear_hansen_gfc_lossyear_10s_080w.tif" rename to o_128_lossyear_hansen_gfc_10s_080w;
alter table "o_128_lossyear_hansen_gfc_lossyear_10s_070w.tif" rename to o_128_lossyear_hansen_gfc_10s_070w;
alter table "o_128_lossyear_hansen_gfc_lossyear_10s_060w.tif" rename to o_128_lossyear_hansen_gfc_10s_060w;

-- dump raster as poly and drop raster 
DO $$
DECLARE
    tbl_name text;
BEGIN
    FOR tbl_name IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_name LIKE 'o_128_lossyear_%'
    LOOP
        RAISE NOTICE 'Current table being processed: %', tbl_name;
        EXECUTE format('CREATE TABLE %I_poly AS SELECT (ST_DumpAsPolygons(r.rast, 1)).* FROM %I r;', tbl_name, tbl_name);
        EXECUTE format ('DROP TABLE IF EXISTS %I;', tbl_name);
    END LOOP;
END $$;   

-- DROP OG TABLES (ONLY THOSE WITHOUT .TIF)
DO $$
DECLARE
    tbl_name text;
BEGIN
    FOR tbl_name IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_name LIKE 'lossyear_hansen%'
            AND NOT table_name LIKE '%_poly'
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS "%I";', tbl_name);
    END LOOP;
END $$;

-- Append POLY TABLES
drop table if exists lossyear_poly;
CREATE TABLE IF NOT EXISTS lossyear_poly AS 
SELECT * FROM o_128_lossyear_hansen_gfc_10n_080w_poly LIMIT 0;

DO $$
DECLARE
    poly_table TEXT;
BEGIN
    FOR poly_table IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_name LIKE 'o_128_lossyear_%_poly' 
    loop
	   --  RAISE NOTICE 'Appended data from table %.', poly_table;
        EXECUTE format('INSERT INTO lossyear_poly SELECT * FROM %I;', poly_table);
        EXECUTE format ('DROP TABLE IF EXISTS %I;', poly_table);
    END LOOP;
end $$;

-- ----------------------------------------------------------------------------------------------
-- GAIN -- 
-- ----------------------------------------------------------------------------------------------
-- RENAMINE TABLES
alter table "gain_hansen_gfc_gain_00n_050w.tif" rename to gain_hansen_gfc_00n_050w;
alter table "gain_hansen_gfc_gain_00n_060w.tif" rename to gain_hansen_gfc_00n_060w;
alter table "gain_hansen_gfc_gain_00n_070w.tif" rename to gain_hansen_gfc_00n_070w;
alter table "gain_hansen_gfc_gain_00n_080w.tif" rename to gain_hansen_gfc_00n_080w;
alter table "gain_hansen_gfc_gain_10n_060w.tif" rename to gain_hansen_gfc_10n_060w;
alter table "gain_hansen_gfc_gain_10n_070w.tif" rename to gain_hansen_gfc_10n_070w;
alter table "gain_hansen_gfc_gain_10s_070w.tif" rename to gain_hansen_gfc_10s_070w;
alter table "gain_hansen_gfc_gain_10s_080w.tif" rename to gain_hansen_gfc_10s_080w;

alter table "o_128_gain_hansen_gfc_gain_00n_050w.tif" rename to o_128_gain_hansen_gfc_00n_050w;
alter table "o_128_gain_hansen_gfc_gain_00n_060w.tif" rename to o_128_gain_hansen_gfc_00n_060w;
alter table "o_128_gain_hansen_gfc_gain_00n_070w.tif" rename to o_128_gain_hansen_gfc_00n_070w;
alter table "o_128_gain_hansen_gfc_gain_00n_080w.tif" rename to o_128_gain_hansen_gfc_00n_080w;
alter table "o_128_gain_hansen_gfc_gain_10n_060w.tif" rename to o_128_gain_hansen_gfc_10n_060w;
alter table "o_128_gain_hansen_gfc_gain_10n_070w.tif" rename to o_128_gain_hansen_gfc_10n_070w;
alter table "o_128_gain_hansen_gfc_gain_10s_070w.tif" rename to o_128_gain_hansen_gfc_10s_070w;
alter table "o_128_gain_hansen_gfc_gain_10s_080w.tif" rename to o_128_gain_hansen_gfc_10s_080w;

-- dump raster as poly and drop raster 
DO $$
DECLARE
    tbl_name text;
BEGIN
    FOR tbl_name IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_name LIKE 'o_128_gain_%'
    LOOP
        RAISE NOTICE 'Current table being processed: %', tbl_name;
        EXECUTE format('CREATE TABLE %I_poly AS SELECT (ST_DumpAsPolygons(r.rast, 1)).* FROM %I r;', tbl_name, tbl_name);
        EXECUTE format ('DROP TABLE IF EXISTS %I;', tbl_name);
    END LOOP;
END $$;   

-- DROP OG TABLES (ONLY THOSE WITHOUT .TIF)
DO $$
DECLARE
    tbl_name text;
BEGIN
    FOR tbl_name IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_name LIKE 'gain_hansen%'
            AND NOT table_name LIKE '%_poly'
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS "%I";', tbl_name);
    END LOOP;
END $$;

Append POLY TABLES
drop table if exists gain_poly;
CREATE TABLE IF NOT EXISTS gain_poly AS 
SELECT * FROM o_128_gain_hansen_gfc_10n_070w_poly LIMIT 0;

DO $$
DECLARE
    poly_table TEXT;
BEGIN
    FOR poly_table IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_name LIKE 'o_128_gain_%_poly' 
    loop
	   --  RAISE NOTICE 'Appended data from table %.', poly_table;
        EXECUTE format('INSERT INTO gain_poly SELECT * FROM %I;', poly_table);
        EXECUTE format ('DROP TABLE IF EXISTS %I;', poly_table);
    END LOOP;
end $$;

-- ----------------------------------------------------------------------------------------------
-- COVER OG-- 
-- ----------------------------------------------------------------------------------------------
-- RENAMINE TABLES
alter table "o_128_cover_hansen_gfc_treecover2000_10n_080w.tif" rename to o_128_cover_hansen_gfc_10n_080w;
alter table "o_128_cover_hansen_gfc_treecover2000_00n_070w.tif" rename to o_128_cover_hansen_gfc_00n_070w;
alter table "cover_hansen_gfc_treecover2000_10n_080w.tif" rename to cover_hansen_gfc_10n_080w;
alter table "cover_hansen_gfc_treecover2000_00n_070w.tif" rename to cover_hansen_gfc_00n_070w;

-- dump raster as poly and drop raster 
DO $$
DECLARE
    tbl_name text;
BEGIN
    FOR tbl_name IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_name LIKE 'o_128_cover_%'
    LOOP
        RAISE NOTICE 'Current table being processed: %', tbl_name;
        EXECUTE format('CREATE TABLE %I_poly AS SELECT (ST_DumpAsPolygons(r.rast, 1)).* FROM %I r;', tbl_name, tbl_name);
        EXECUTE format ('DROP TABLE IF EXISTS %I;', tbl_name);
    END LOOP;
END $$;   

-- DROP OG TABLES (ONLY THOSE WITHOUT .TIF)
DO $$
DECLARE
    tbl_name text;
BEGIN
    FOR tbl_name IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_name LIKE 'cover_hansen%'
            AND NOT table_name LIKE '%_poly'
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS "%I";', tbl_name);
    END LOOP;
END $$;

-- Append POLY TABLES
drop table if exists cover_poly;
CREATE TABLE IF NOT EXISTS cover_poly AS 
SELECT * FROM o_128_cover_hansen_gfc_10n_080w_poly LIMIT 0;

DO $$
DECLARE
    poly_table TEXT;
BEGIN
    FOR poly_table IN
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
            AND table_name LIKE 'o_128_cover_%_poly' 
    loop
	   --  RAISE NOTICE 'Appended data from table %.', poly_table;
        EXECUTE format('INSERT INTO cover_poly SELECT * FROM %I;', poly_table);
        EXECUTE format ('DROP TABLE IF EXISTS %I;', poly_table);
    END LOOP;
end $$;

select table_name FROM information_schema.tables WHERE table_schema = 'public';

-- ----------------------------------------------------------------------------------------------
-- LANCZOS COVER --
-- ----------------------------------------------------------------------------------------------
-- RENAMINE TABLES
-- alter table "treecover_00n_060w_lanczos.tif" rename to treecover_00n_060w_lanczos;
-- alter table "treecover_00n_070w_lanczos.tif" rename to treecover_00n_070w_lanczos;
-- alter table "treecover_00n_080w_lanczos.tif" rename to treecover_00n_080w_lanczos;
-- alter table "treecover_10n_060w_lanczos.tif" rename to treecover_10n_060w_lanczos;
-- alter table "treecover_10n_070w_lanczos.tif" rename to treecover_10n_070w_lanczos;

-- -- dump raster as poly and drop raster 
-- DO $$
-- DECLARE
--     tbl_name text;
-- BEGIN
--     FOR tbl_name IN
--         SELECT table_name 
--         FROM information_schema.tables 
--         WHERE table_name LIKE 'treecover_%'
--     LOOP
--         RAISE NOTICE 'Current table being processed: %', tbl_name;
--         EXECUTE format('CREATE TABLE %I_poly AS SELECT (ST_DumpAsPolygons(r.rast, 1)).* FROM %I r;', tbl_name, tbl_name);
--         EXECUTE format ('DROP TABLE IF EXISTS %I;', tbl_name);
--     END LOOP;
-- END $$;   

-- -- Append POLY TABLES
-- drop table if exists cover_poly;
-- CREATE TABLE IF NOT EXISTS cover_poly AS 
-- SELECT * FROM treecover_00n_060w_lanczos_poly LIMIT 0;

-- DO $$
-- DECLARE
--     poly_table TEXT;
-- BEGIN
--     FOR poly_table IN
--         SELECT table_name 
--         FROM information_schema.tables 
--         WHERE table_schema = 'public' 
--             AND table_name LIKE 'treecover_%_poly' 
--     loop
-- 	   --  RAISE NOTICE 'Appended data from table %.', poly_table;
--         EXECUTE format('INSERT INTO cover_poly SELECT * FROM %I;', poly_table);
--         EXECUTE format ('DROP TABLE IF EXISTS %I;', poly_table);
--     END LOOP;
-- end $$;

-- select table_name FROM information_schema.tables WHERE table_schema = 'public';