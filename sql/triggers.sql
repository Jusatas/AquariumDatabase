
-- Fish that are jurinis should be in jurinis and gelavandenis should be in gelavandenis
CREATE OR REPLACE FUNCTION fish_environment_check()
RETURNS TRIGGER AS $$
DECLARE aquarium_type VARCHAR(20);
BEGIN
	SELECT Tipas
	INTO aquarium_type
	FROM judr0384.Akvariumas
	WHERE ID = NEW.AkvariumoID;

	IF NEW.AkvTipas != aquarium_type THEN
		RAISE EXCEPTION '% tipo zuvis negali gyventi % akvariume',
			NEW.AkvTipas, aquarium_type;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Aplinka
BEFORE INSERT OR UPDATE ON judr0384.Zuvis
FOR EACH ROW
EXECUTE FUNCTION fish_environment_check();




-- Fish size and aggresiveness checks when adding
CREATE OR REPLACE FUNCTION fish_size_check()
RETURNS TRIGGER AS $$
DECLARE
	aquarium_safe BOOLEAN;
	largest_aggr_max_size DECIMAL (5,2) := 0;
	smallest_non_aggr_size DECIMAL (5,2) := 0;
	smallest_aggr_size DECIMAL (5,2) := 0;
BEGIN
	SELECT Saugumas,
	 COALESCE(didziausias_agresyvus_max, 0),
	 COALESCE(maziausias_neagresyvus, 0),
	 COALESCE(maziausias_agresyvus, 0)
	INTO aquarium_safe, largest_aggr_max_size, smallest_non_aggr_size, smallest_aggr_size
	FROM judr0384.AkvariumuInfo
	WHERE ID = NEW.AkvariumoID;

	IF aquarium_safe THEN RETURN NEW;
	END IF;

	
	IF NEW.Agresyvi THEN
		IF smallest_aggr_size > 0 AND
		NEW.MaxDydis > smallest_aggr_size * 1.5 THEN
			RAISE EXCEPTION 'Aggresyvios zuvies max dydis negali virsyti 50%% maziausios agresyvios zuvies dydzio';
		END IF;
		
		IF smallest_non_aggr_size > 0 AND
		NEW.MaxDydis > smallest_non_aggr_size * 1.2 THEN
			RAISE EXCEPTION 'Agresyvios zuvies max dydis negali virsyti maziausios neagresyvios zuvies dydzio daugiau nei 20%%';
		END IF;

	ELSE
		IF largest_aggr_max_size > 0 AND
		NEW.Dydis < largest_aggr_max_size * 0.8 THEN
			RAISE EXCEPTION 'Neagresyvios zuvies dabartinis dydis privalo sudaryti 80%% didziausios agresyvios zuvies maksimalaus dydzio';
		END IF;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Dydis
BEFORE INSERT OR UPDATE ON judr0384.Zuvis
FOR EACH ROW
EXECUTE FUNCTION fish_size_check();





--
CREATE OR REPLACE FUNCTION biomass_check()
RETURNS TRIGGER AS $$
DECLARE
    aquarium_safety BOOLEAN;
    aquarium_volume NUMERIC(7,2);
    max_biomass NUMERIC(7,2);
    current_biomass NUMERIC(7,2);
BEGIN
    SELECT 
        Saugumas, 
        Talpa
    INTO 
        aquarium_safety, 
        aquarium_volume
    FROM judr0384.Akvariumas 
    WHERE ID = NEW.AkvariumoID;

    max_biomass := aquarium_volume * 0.65;

    -- Calculate current biomass including the new fish
    SELECT COALESCE(SUM(Dydis * 1.3), 0) + (NEW.Dydis * 1.3)
    INTO current_biomass
    FROM judr0384.Zuvis
    WHERE AkvariumoID = NEW.AkvariumoID;

    IF current_biomass > max_biomass THEN
        RAISE EXCEPTION 'Pridejus sia zuvi (dydis: %.2f) perpildytu akvariuma ID %   (dabartine biomase: %.2f, max biomase: %.2f)', 
            NEW.Dydis, NEW.AkvariumoID, current_biomass, max_biomass;
    END IF;

	 UPDATE judr0384.Akvariumas
	 SET Biomase = current_biomass
	 WHERE ID = NEW.AkvariumoID;
	
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--

CREATE TRIGGER Biomase
BEFORE INSERT OR UPDATE ON judr0384.Zuvis
FOR EACH ROW
EXECUTE FUNCTION biomass_check();



CREATE OR REPLACE FUNCTION last_caretaker_check()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM judr0384.Prieziura pr
        JOIN judr0384.AkvariumuInfo ai ON ai.ID = pr.AkvariumoID
        WHERE pr.PriziuretojoID = OLD.ID
        AND pr.Pabaiga IS NULL
        AND ai.ZuvuSkaicius > 0
        AND NOT EXISTS (
            SELECT 1
            FROM judr0384.Prieziura p2
            WHERE p2.AkvariumoID = pr.AkvariumoID
            AND p2.PriziuretojoID != OLD.ID
            AND p2.Pabaiga IS NULL
        )
    ) THEN
        RAISE EXCEPTION 'Negalima pasalinti priziuretojo ID %, nes tai paskutinis aktyvus priziuretojas bent vienam akvariumui su bent viena zuvimi.', 
            OLD.ID;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Last_Caretaker
BEFORE DELETE ON judr0384.Priziuretojas
FOR EACH ROW
EXECUTE FUNCTION last_caretaker_check();


CREATE OR REPLACE FUNCTION caretaker_qualification_check()
RETURNS TRIGGER AS $$
DECLARE
    caretaker_qualification VARCHAR(20);
    aquarium_type VARCHAR(15);
BEGIN

    SELECT Kvalifikacija INTO caretaker_qualification
    FROM judr0384.Priziuretojas
    WHERE ID = NEW.PriziuretojoID;

    SELECT Tipas INTO aquarium_type
    FROM judr0384.Akvariumas
    WHERE ID = NEW.AkvariumoID;

    IF caretaker_qualification = 'Gelavandenis' AND aquarium_type = 'Jurinis' THEN
        RAISE EXCEPTION 'Tik Gelavandeniu kvalifikacija turintis priziuretojas negali priziureti jurinio akvariumo.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Qualification_Check
BEFORE INSERT OR UPDATE ON judr0384.Prieziura
FOR EACH ROW
EXECUTE FUNCTION caretaker_qualification_check();



CREATE OR REPLACE FUNCTION refresh_aquariums_info()
RETURNS TRIGGER AS $$
BEGIN
	REFRESH MATERIALIZED VIEW judr0384.AkvariumuInfo;
	RETURN NEW;
END 
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_biomass_on_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE judr0384.Akvariumas
    SET Biomase = COALESCE(
        (SELECT SUM(Dydis * 1.3)
        FROM judr0384.Zuvis
        WHERE AkvariumoID = OLD.AkvariumoID
        AND ID != OLD.ID), 0)
    WHERE ID = OLD.AkvariumoID;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Biomase_Delete
AFTER DELETE ON judr0384.Zuvis
FOR EACH ROW
EXECUTE FUNCTION update_biomass_on_delete();

CREATE OR REPLACE FUNCTION check_care_end()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM judr0384.AkvariumuInfo ai
        WHERE ai.ID = OLD.AkvariumoID 
        AND ai.ZuvuSkaicius > 0
    ) AND NOT EXISTS (
        SELECT 1 
        FROM judr0384.Prieziura
        WHERE AkvariumoID = OLD.AkvariumoID
        AND PriziuretojoID != OLD.PriziuretojoID
        AND Pabaiga IS NULL
    ) THEN
        RAISE EXCEPTION 'Negalima nutraukti prieziuros akvariumui %, nes jame yra zuvu ir jis neturi daugiau priziuretoju.', 
            OLD.AkvariumoID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Check_Care_End
BEFORE UPDATE OF Pabaiga ON judr0384.Prieziura
FOR EACH ROW
WHEN (OLD.Pabaiga IS NULL AND NEW.Pabaiga IS NOT NULL)
EXECUTE FUNCTION check_care_end();

CREATE OR REPLACE FUNCTION ensure_caretaker_on_fish_addition()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM judr0384.Dirbantys 
        WHERE Akvariumas = NEW.AkvariumoID
    ) THEN
        RAISE EXCEPTION 'Negalima prideti zuvies i akvariuma %, nes jis neturi priziuretoju.', 
            NEW.AkvariumoID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Ensure_Caretaker_Fish_Addition
BEFORE INSERT ON judr0384.Zuvis
FOR EACH ROW
EXECUTE FUNCTION ensure_caretaker_on_fish_addition();

-- refresh materialized view after Zuvis table operations
CREATE TRIGGER update_aquariums_info
AFTER INSERT OR UPDATE OR DELETE ON judr0384.Zuvis
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_aquariums_info();

-- refresh materialized view after Akvariumas table operations
CREATE TRIGGER update_aquariums_info_akvariumas
AFTER INSERT OR UPDATE OR DELETE ON judr0384.Akvariumas
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_aquariums_info();