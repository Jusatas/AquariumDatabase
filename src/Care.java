import java.sql.Connection;
import java.util.Scanner;

public class Care {
    public static void manageCareActions(Connection conn, Scanner scanner) {
        while (true) {
            System.out.println("\n--- Tvarkyti Prieziuras ---");
            System.out.println("1. Isvesti Prieziuras");
            System.out.println("2. Priskirti priziuretoja akvariumui");
            System.out.println("3. Nutraukti priziuretojo paskyrima");
            System.out.println("4. Exit");
            System.out.print("Pasirinkimas: ");
            int choice = DatabaseUtils.getIntInput(scanner);

            switch (choice) {
                case 1 -> listCares(conn);
                case 2 -> assignCaretaker(conn, scanner);
                case 3 -> endAssignment(conn, scanner);
                case 4 -> { return; }
                default -> System.out.println("Netinkamas pasirinkimas, bandykite dar karta.");
            }
        }
    }

    public static void assignCaretaker(Connection conn, Scanner scanner) {
        System.out.print("Priziuretojo ID: ");
        int caretakerId = DatabaseUtils.getIntInput(scanner);
        System.out.print("Akvariumo ID: ");
        int aquariumId = DatabaseUtils.getIntInput(scanner);

        String query = """
            INSERT INTO judr0384.Prieziura (PriziuretojoID, AkvariumoID, Pradzia)
            VALUES (?, ?, CURRENT_DATE)
            """;

        if (DatabaseUtils.executeUpdate(conn, query, caretakerId, aquariumId)) {
            System.out.println("Priziuretojas priskirtas sekmingai.");
        }
    }

    public static void endAssignment(Connection conn, Scanner scanner) {
        System.out.print("Priziuretojo ID: ");
        int caretakerId = DatabaseUtils.getIntInput(scanner);
        System.out.print("Akvariumo ID: ");
        int aquariumId = DatabaseUtils.getIntInput(scanner);

        String query = """
            UPDATE judr0384.Prieziura
            SET Pabaiga = CURRENT_DATE
            WHERE PriziuretojoID = ? AND AkvariumoID = ?
            """;

        if (DatabaseUtils.executeUpdate(conn, query, caretakerId, aquariumId)) {
            System.out.println("Priskyrimas sekmingai uzbaigtas.");
        }
    }

    public static void listCares(Connection conn) {
        String query = "SELECT * FROM judr0384.Prieziura";
        DatabaseUtils.listTable(conn, query, "Prieziura");
    }
}
