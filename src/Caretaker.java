import java.sql.Connection;
import java.util.Scanner;

public class Caretaker {
    public static void updateCaretaker(Connection conn, Scanner scanner) {
        System.out.print("Enter Caretaker ID to update: ");
        int caretakerId = DatabaseUtils.getIntInput(scanner);
        scanner.nextLine();
    
        System.out.print("Vardas: ");
        String newFirstName = scanner.nextLine();
    
        System.out.print("Pavarde: ");
        String newLastName = scanner.nextLine();
    
        System.out.print("Kvalifikacija (Jurinis/Gelavandenis): ");
        String newQualification = scanner.nextLine();
    
        System.out.print("Atlygis: ");
        double newSalary = DatabaseUtils.getDoubleInput(scanner);
    
        String query = """
            UPDATE judr0384.Priziuretojas
            SET Vardas = ?, Pavarde = ?, Kvalifikacija = ?, Atlyginimas = ?
            WHERE ID = ?;
            """;
    
        if (DatabaseUtils.executeUpdate(conn, query, newFirstName, newLastName, newQualification, newSalary, caretakerId)) {
            System.out.println("Priziuretojas sekmingai atnaujintas.");
        } else {
            System.out.println("Nepavyko atnaujinti priziuretojo.");
        }
    }    

    public static void manageCaretakers(Connection conn, Scanner scanner) {
        while (true) {
            System.out.println("\n--- Tvarkyti Priziuretojus---");
            System.out.println("1. Isvesti Priziuretojus");
            System.out.println("2. Prideti Priziuretoja");
            System.out.println("3. Atnaujinti Priziuretoja"); 
            System.out.println("4. Pasalinti Priziuretoja");
            System.out.println("5. Exit");
            System.out.print("Pasirinkimas: ");
            int choice = DatabaseUtils.getIntInput(scanner);

            switch (choice) {
                case 1 -> listCaretakers(conn);
                case 2 -> addCaretaker(conn, scanner);
                case 3 -> updateCaretaker(conn, scanner);
                case 4 -> deleteCaretaker(conn, scanner);
                case 5 -> { return; }
                default -> System.out.println("Neteisingas pasirinkimas, bandykite dar karta.");
            }
        }
    }

    public static void listCaretakers(Connection conn) {
        String query = "SELECT * FROM judr0384.Priziuretojas";
        DatabaseUtils.listTable(conn, query, "Caretakers");
    }

    public static void addCaretaker(Connection conn, Scanner scanner) {
        scanner.nextLine();
        System.out.print("Vardas: ");
        String firstName = scanner.nextLine();
        System.out.print("Pavarde: ");
        String lastName = scanner.nextLine();
        System.out.print("Issilavinimas (Jurinis/Gelavandenis): ");
        String qualification = scanner.nextLine();
        System.out.print("Atlyginimas: ");
        double salary = DatabaseUtils.getDoubleInput(scanner);

        String query = """
            INSERT INTO judr0384.Priziuretojas (Vardas, Pavarde, Kvalifikacija, Atlyginimas)
            VALUES (?, ?, ?, ?)
            """;

        if (DatabaseUtils.executeUpdate(conn, query, firstName, lastName, qualification, salary)) {
            System.out.println("Priziuretojas sekmingai pridetas");
        }
    }

    public static void deleteCaretaker(Connection conn, Scanner scanner) {
        System.out.print("Salinamo priziuretojo ID: ");
        int caretakerId = DatabaseUtils.getIntInput(scanner);

        String query = "DELETE FROM judr0384.Priziuretojas WHERE ID = ?";
        if (DatabaseUtils.executeUpdate(conn, query, caretakerId)) {
            System.out.println("Priziuretojas sekmingai pasalintas");
        }
    }
}
