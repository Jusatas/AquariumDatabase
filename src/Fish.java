import java.sql.Connection;
import java.util.Scanner;

public class Fish {
    public static void manageFishes(Connection conn, Scanner scanner) {
        while (true) {
            System.out.println("\n--- Tvarkyti Zuvis ---");
            System.out.println("1. Isvesti Zuvis");
            System.out.println("2. Prideti Zuvi");
            System.out.println("3. Atnaujinti Zuvi");
            System.out.println("4. Salinti Zuvi");
            System.out.println("5. Exit");
            System.out.print("Pasirinkimas: ");
            int choice = DatabaseUtils.getIntInput(scanner);

            switch (choice) {
                case 1 -> listFishes(conn);
                case 2 -> addFish(conn, scanner);
                case 3 -> updateFish(conn, scanner);
                case 4 -> deleteFish(conn, scanner);
                case 5 -> { return; }
                default -> System.out.println("Invalid choice. Try again.");
            }
        }
    }

    public static void listFishes(Connection conn) {
        String query = """
            SELECT z.ID, z.TrivPav AS CommonName, z.Gentis AS Genus, z.Rusis AS Species, z.Dydis AS Size, 
                   z.MaxDydis AS MaxSize, z.Agresyvi AS Aggressive, a.Tipas AS AquariumType
            FROM judr0384.Zuvis z
            JOIN judr0384.Akvariumas a ON z.AkvariumoID = a.ID;
            """;
        DatabaseUtils.listTable(conn, query, "Fishes");
    }

    public static void updateFish(Connection conn, Scanner scanner) {
        System.out.print("Enter Fish ID to update: ");
        int fishId = DatabaseUtils.getIntInput(scanner);
        scanner.nextLine();
    
        System.out.print("New Aquarium ID: ");
        int newAquariumId = DatabaseUtils.getIntInput(scanner);
        scanner.nextLine();
    
        System.out.print("New Size: ");
        double newSize = DatabaseUtils.getDoubleInput(scanner);
    
        System.out.print("New Max Size: ");
        double newMaxSize = DatabaseUtils.getDoubleInput(scanner);
        scanner.nextLine();
    
        System.out.print("New Food Type (Sausas/Gyvas): ");
        String newFoodType = scanner.nextLine();
    
        System.out.print("New Aquarium Type (Jurinis/Gelavandenis): ");
        String newAquariumType = scanner.nextLine();
    
        String query = """
            UPDATE judr0384.Zuvis
            SET AkvariumoID = ?, Dydis = ?, MaxDydis = ?, Pasaras = ?, AkvTipas = ?
            WHERE ID = ?;
            """;
    
        if (DatabaseUtils.executeUpdate(conn, query, newAquariumId, newSize, newMaxSize, newFoodType, newAquariumType, fishId)) {
            System.out.println("Zuvis sekmingai atnaujinta.");
        } else {
            System.out.println("Nepavyko atnaujinti zuvies.");
        }
    }
    

    public static void addFish(Connection conn, Scanner scanner) {
        System.out.print("Akvariumo ID: ");
        int aquariumId = DatabaseUtils.getIntInput(scanner);
        scanner.nextLine();
        
        System.out.print("Gentis: ");
        String genus = scanner.nextLine();
        
        System.out.print("Rusis: ");
        String species = scanner.nextLine();
        
        System.out.print("Trivialus pavadinimas: ");
        String commonName = scanner.nextLine();
        
        System.out.print("Dydis: ");
        double size = DatabaseUtils.getDoubleInput(scanner);
        
        System.out.print("Max dydis: ");
        double maxSize = DatabaseUtils.getDoubleInput(scanner);
        scanner.nextLine(); 
        
        System.out.print("Ar zuvis agresyvi? (true/false): ");
        boolean aggressive =  DatabaseUtils.getBooleanInput(scanner);
        scanner.nextLine();
        
        System.out.print("Maisto tipas (Sausas/Gyvas): ");
        String foodType = scanner.nextLine();
        
        System.out.print("Akvariumo tipas (Jurinis/Gelavandenis): ");
        String aquariumType = scanner.nextLine();

        String query = """
            INSERT INTO judr0384.Zuvis (AkvariumoID, Gentis, Rusis, TrivPav, Dydis, MaxDydis, Agresyvi, Pasaras, AkvTipas)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
            """;

        if (DatabaseUtils.executeUpdate(conn, query, aquariumId, genus, species, commonName, size, maxSize, 
                                      aggressive, foodType, aquariumType)) {
            System.out.println("Zuvis prideta sekmingai.");
        }
    }

    public static void deleteFish(Connection conn, Scanner scanner) {
        System.out.print("Iveskite salinamos zuvies ID: ");
        int fishId = DatabaseUtils.getIntInput(scanner);

        String query = "DELETE FROM judr0384.Zuvis WHERE ID = ?";
        if (DatabaseUtils.executeUpdate(conn, query, fishId)) {
            System.out.println("Zuvis sekmingai pasalinta.");
        } else {
            System.out.println("Zuvies pasalinimo klaida, patikrinkite ID.");
        }
    }
}
