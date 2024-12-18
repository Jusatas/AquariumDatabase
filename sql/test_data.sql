REFRESH MATERIALIZED VIEW judr0384.AkvariumuInfo;

INSERT INTO judr0384.Akvariumas (Tipas, Talpa, Saugumas)
VALUES
        ('Jurinis', 300, FALSE),
        ('Jurinis', 2500, TRUE),
        ('Gelavandenis', 1000, FALSE),
        ('Gelavandenis', 50, FALSE),
        ('Gelavandenis', 500, TRUE);

-- Succesful inserts
INSERT INTO judr0384.Zuvis (AkvariumoID, Pasaras, Dydis, MaxDydis, Agresyvi, AkvTipas, Gentis, Rusis, TrivPav)
VALUES
        (1, 'Sausas', 15, 20, FALSE, 'Jurinis', 'Carassius', 'Auratus', 'Auksine Zuvele'),
        (2, 'Sausas', 8, 12, FALSE, 'Jurinis', 'Danio', 'Rerio', 'Zebrine Danija');

-- Successful insert without optional values
INSERT INTO judr0384.Zuvis (AkvariumoID, Pasaras, Dydis, MaxDydis, AkvTipas, Gentis, Rusis)
VALUES (5, 'Gyvas', 5, 10., 'Gelavandenis', 'Betta', 'Splendens');

-- Fail (Dydis should not be greater than MaxDydis)
INSERT INTO judr0384.Zuvis (AkvariumoID, Pasaras, Dydis, MaxDydis, Agresyvi, AkvTipas, Gentis, Rusis, TrivPav)
VALUES (3, 'Gyvas', -1, 5, TRUE, 'Gelavandenis', 'Guppy', 'Reticulata', 'Magiska Gupija');

-- Succesful insert - correct aquarium type
INSERT INTO judr0384.Zuvis (AkvariumoID, Pasaras, Dydis, MaxDydis, Agresyvi, AkvTipas, Gentis, Rusis, TrivPav)
VALUES (1, 'Gyvas', 10, 15, TRUE, 'Jurinis', 'Clownfish', 'Ocellaris', 'Zuvis Klounas');

-- Fail - wrong water type
INSERT INTO judr0384.Zuvis (AkvariumoID, Pasaras, Dydis, MaxDydis, Agresyvi, AkvTipas, Gentis, Rusis, TrivPav)
VALUES (1, 'Gyvas', 10, 15, TRUE, 'Gelavandenis', 'Tetra', 'Neon', 'Nesekminga Neonzuve');


-- Caretakers
INSERT INTO judr0384.Priziuretojas (Kvalifikacija, Atlyginimas, Vardas, Pavarde)
VALUES
    ('Jurinis', 2000.00, 'Jonas', 'Petrauskas'),
    ('Gelavandenis', 1800.50, 'Matas', 'Knatas'),
    ('Jurinis', 2500.75, 'Egle', 'Andraite'),
    ('Gelavandenis', 2200.00, 'Petras', 'Rudasis'),
    ('Jurinis', 3000.00, 'Tomas', 'Bingas');


-- Prieziuros
INSERT INTO judr0384.Prieziura (Pradzia, Pabaiga, PriziuretojoID, AkvariumoID)
VALUES
        ('2024-01-01', '2024-06-01', 1, 1), -- Jonas manages the 1st aquarium
        ('2024-03-01', NULL, 2, 2),        -- Austeja manages the 2nd aquarium, still going
        ('2024-02-15', '2024-09-15', 3, 2),-- Egle managed the 2nd aquarium with Austeja for a time
        ('2024-04-01', '2024-05-01', 4, 4),-- Petras  managed the 4th aquarium
        ('2024-07-01', NULL, 5, 5);        -- Tomas manages the 5th aquarium, still going

REFRESH MATERIALIZED VIEW judr0384.AkvariumuInfo;