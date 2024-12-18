DROP TABLE IF EXISTS judr0384.Prieziura CASCADE;
DROP TABLE IF EXISTS judr0384.Akvariumas CASCADE;
DROP TABLE IF EXISTS judr0384.Priziuretojas CASCADE;
DROP TABLE IF EXISTS judr0384.Zuvis CASCADE;

DROP VIEW IF EXISTS judr0384.Apkrova;
DROP VIEW IF EXISTS judr0384.Dirbantys;
DROP VIEW IF EXISTS judr0384.ZuvysAkvariumuose;
DROP MATERIALIZED VIEW IF EXISTS judr0384.AkvariumuInfo;

CREATE TABLE judr0384.Priziuretojas (
    ID SERIAL PRIMARY KEY,
    Kvalifikacija VARCHAR(20) CHECK (Kvalifikacija IN ('Jurinis', 'Gelavandenis')),
    Atlyginimas NUMERIC(10, 2) CHECK (Atlyginimas > 0),
    Vardas VARCHAR(50),
    Pavarde VARCHAR(50)
);

CREATE TABLE judr0384.Akvariumas (
	ID SERIAL PRIMARY KEY,
	Tipas VARCHAR(15) CHECK (Tipas IN ('Jurinis', 'Gelavandenis')),
	Talpa DECIMAL(7, 2) CHECK (Talpa > 0),
	Saugumas BOOLEAN DEFAULT FALSE,
	Biomase NUMERIC (7,2) DEFAULT 0
);

CREATE TABLE judr0384.Prieziura (
    Pradzia DATE, --todo
    Pabaiga DATE,
    PriziuretojoID INTEGER REFERENCES judr0384.Priziuretojas(ID),
    AkvariumoID INTEGER REFERENCES judr0384.Akvariumas(ID),
    PRIMARY KEY (PriziuretojoID, AkvariumoID) 
);

CREATE TABLE judr0384.Zuvis (
	ID SERIAL PRIMARY KEY,
	AkvariumoID INTEGER REFERENCES judr0384.Akvariumas(ID),
	Pasaras VARCHAR (10) CHECK (Pasaras IN ('Sausas', 'Gyvas')),
	Dydis DECIMAL(5, 2) CHECK (Dydis > 0),
	MaxDydis DECIMAL (5, 2) CHECK (MaxDydis > Dydis),
	Agresyvi BOOLEAN DEFAULT TRUE,
	AkvTipas VARCHAR(20) CHECK (AkvTipas IN ('Jurinis', 'Gelavandenis')),
	Gentis VARCHAR(50),
	Rusis VARCHAR(50),
	TrivPav VARCHAR(50) 
);

-- Frequently queried information
CREATE INDEX idx_priziuretojas_name ON judr0384.Priziuretojas(Vardas, Pavarde);
CREATE INDEX idx_zuvis_akvariumas_agresyvi ON judr0384.Zuvis(AkvariumoID, Agresyvi);
CREATE INDEX idx_akvariumas_id_saugumas ON judr0384.Akvariumas(ID, Saugumas);


-- Unique index to protect against accidental addition of priziuretojas twice
CREATE UNIQUE INDEX idx_unique_prieziura ON judr0384.Prieziura(PriziuretojoID, AkvariumoID, Pradzia);

-- Frequently used information for sorting
CREATE INDEX idx_akvariumas_talpa ON judr0384.Akvariumas(Talpa);



CREATE VIEW judr0384.Dirbantys AS
SELECT 
	p.Vardas || ' ' || p.Pavarde AS Priziuretojas,
	a.ID AS Akvariumas,
	a.Tipas AS AquariumoTipas,
	pr.Pradzia AS PradziosData
FROM judr0384.Priziuretojas p
JOIN judr0384.Prieziura pr ON p.ID = pr.PriziuretojoID
JOIN judr0384.Akvariumas a ON pr.AkvariumoID = a.ID
WHERE pr.Pabaiga IS NULL;

CREATE VIEW judr0384.ZuvysAkvariumuose AS
SELECT 
	a.ID AS Akvariumas,
	z.ID AS Zuvis,
	z.TrivPav AS TrivPavadinimas,
	z.Gentis || ' ' || z.Rusis AS LotPavadinimas,
	z.Dydis AS Dydis,
	z.MaxDydis AS MaxDydis,
	z.Agresyvi AS Agresyvi,
	a.Tipas AS Tipas,
	a.Talpa AS Talpa,
	a.Saugumas AS Saugus
FROM judr0384.Zuvis z
JOIN judr0384.Akvariumas a ON z.AkvariumoID = a.ID;

CREATE MATERIALIZED VIEW judr0384.AkvariumuInfo AS
SELECT 
	a.ID AS ID,
	a.Tipas AS Tipas,
	COUNT(z.ID) AS ZuvuSkaicius,
	AVG(z.Dydis) AS AvgZuvis,
	MAX(z.Dydis) AS MaxZuvis,
	SUM(z.Dydis) AS DydziuSuma,
	MAX (CASE WHEN z.Agresyvi = TRUE THEN z.MaxDydis ELSE NULL END) AS didziausias_agresyvus_max,
	MIN (CASE WHEN z.Agresyvi = FALSE THEN z.Dydis ELSE NULL END) AS maziausias_neagresyvus,
	MIN (CASE WHEN z.Agresyvi = TRUE THEN z.Dydis ELSE NULL END) AS maziausias_agresyvus,
	a.Saugumas AS Saugumas
FROM judr0384.Akvariumas a
LEFT JOIN judr0384.Zuvis z ON a.ID = z.AkvariumoID
GROUP BY a.ID;