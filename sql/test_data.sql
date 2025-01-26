-- 1. Insert valid Aquariums
INSERT INTO judr0384.Akvariumas (Tipas, Talpa, Saugumas)
VALUES
    ('Jurinis', 300, FALSE),
    ('Jurinis', 2500, TRUE),
    ('Gelavandenis', 1000, FALSE),
    ('Gelavandenis', 50, FALSE),
    ('Gelavandenis', 500, TRUE);

-- 2. Insert valid Caretakers
INSERT INTO judr0384.Priziuretojas (Kvalifikacija, Atlyginimas, Vardas, Pavarde)
VALUES
    ('Jurinis', 2000.00, 'Jonas', 'Petrauskas'),
    ('Jurinis', 1800.50, 'Matas', 'Knatas'),
    ('Gelavandenis', 2500.75, 'Egle', 'Andraite'),
    ('Gelavandenis', 2200.00, 'Petras', 'Rudasis'),
    ('Gelavandenis', 3000.00, 'Tomas', 'Bingas');

-- 3. Insert valid Prieziura entries
INSERT INTO judr0384.Prieziura (Pradzia, Pabaiga, PriziuretojoID, AkvariumoID)
VALUES
    ('2024-01-01', '2024-06-01', 1, 1), -- Jonas manages the 1st aquarium
    ('2024-03-01', NULL, 2, 2),        -- Matas manages the 2nd aquarium, ongoing
    ('2024-02-15', '2024-09-15', 3, 3),-- Egle managed the 3rd aquarium
    ('2024-04-01', '2024-05-01', 4, 4),-- Petras managed the 4th aquarium
    ('2024-07-01', NULL, 5, 5);        -- Tomas manages the 5th aquarium, ongoing

-- 4. Insert valid Fishes
INSERT INTO judr0384.Zuvis (AkvariumoID, Pasaras, Dydis, MaxDydis, Agresyvi, AkvTipas, Gentis, Rusis, TrivPav)
VALUES
    (2, 'Sausas', 15, 20, FALSE, 'Jurinis', 'Carassius', 'Auratus', 'Auksine Zuvele'),
    (5, 'Gyvas', 10, 12, TRUE, 'Gelavandenis', 'Danio', 'Rerio', 'Zebrine Danija');

-- 5. Invalid Cases for Testing
-- Invalid: Fish assigned to nonexistent Aquarium
INSERT INTO judr0384.Zuvis (AkvariumoID, Pasaras, Dydis, MaxDydis, Agresyvi, AkvTipas, Gentis, Rusis, TrivPav)
VALUES (999, 'Gyvas', 10, 15, TRUE, 'Jurinis', 'Invalid', 'Fish', 'Fake Entry');

-- Invalid: Caretaker with Gelavandenis qualification managing Jurinis Aquarium
INSERT INTO judr0384.Prieziura (Pradzia, Pabaiga, PriziuretojoID, AkvariumoID)
VALUES ('2024-08-01', NULL, 2, 1); -- Matas assigned to Jurinis

-- Invalid: Aquarium with no care entry
INSERT INTO judr0384.Akvariumas (Tipas, Talpa, Saugumas)
VALUES ('Jurinis', 500, FALSE); -- Should fail due to `ensure_caretaker_on_aquarium_creation` trigger
