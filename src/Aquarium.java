import java.sql.Connection;
import java.util.Scanner;

public class Aquarium {

    public static void manageAquariums(Connection conn, Scanner scanner) {
        while (true) {
            System.out.println("\n--- Tvarkyti Akvariumus ---");
            System.out.println("1. Isvesti Akvariumus");
            System.out.println("2. Prideti Akvariuma");
            System.out.println("3. Salinti Akvariuma");
            System.out.println("4. Exit");
            System.out.print("Pasirinkimas ");
            int choice = DatabaseUtils.getIntInput(scanner);

            switch (choice) {
                case 1 -> listAquariums(conn);
                case 2 -> addAquarium(conn, scanner);
                case 3 -> deleteAquarium(conn, scanner);
                case 4 -> { return; }
                default -> System.out.println("Netinkamas pasirinkimas, bandykite dar.");
            }
        }
    }

    public static void listAquariums(Connection conn) {
        String query = "SELECT * FROM judr0384.Akvariumas";
        DatabaseUtils.listTable(conn, query, "Aquariums");
    }

    public static void addAquarium(Connection conn, Scanner scanner) {
        scanner.nextLine();
        System.out.print("Tipas (Jurinis/Gelavandenis): ");
        String type = scanner.nextLine();
        System.out.print("Talpa: ");
        double capacity = DatabaseUtils.getDoubleInput(scanner);
        System.out.print("Ar jis saugus? (true/false): ");
        boolean safety = DatabaseUtils.getBooleanInput(scanner);

        String query = """
            INSERT INTO judr0384.Akvariumas (Tipas, Talpa, Saugumas)
            VALUES (?, ?, ?)
            """;

        if (DatabaseUtils.executeUpdate(conn, query, type, capacity, safety)) {
            System.out.println("Akvariumas pridetas sekmingai.");
        }
    }

    public static void deleteAquarium(Connection conn, Scanner scanner) {
        System.out.print("Salinamo akvarimo ID: ");
        int aquariumId = DatabaseUtils.getIntInput(scanner);

        String query = "DELETE FROM judr0384.Akvariumas WHERE ID = ?";
        if (DatabaseUtils.executeUpdate(conn, query, aquariumId)) {
            System.out.println("Akvariumas sekmingai pasalintas.");
        }
    }
}
