import java.sql.Connection;
import java.sql.SQLException;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        try (Connection conn = DatabaseConnection.connect()) {
            Scanner scanner = new Scanner(System.in);
            while (true) {
                System.out.println("=== Akvariumo tvarkymo sistema ===");
                System.out.println("1. Keisti Priziuretojus");
                System.out.println("2. Keisti Akvariumus");
                System.out.println("3. Keisti Zuvis");
                System.out.println("4. Keisti Prieziura");
                System.out.println("5. Isvesti viska: ");
                System.out.println("6. Exit");
                System.out.print("Pasirinkimas: ");
                int choice = DatabaseUtils.getIntInput(scanner);

                switch (choice) {
                    case 1 -> Caretaker.manageCaretakers(conn, scanner);
                    case 2 -> Aquarium.manageAquariums(conn, scanner);
                    case 3 -> Fish.manageFishes(conn, scanner);
                    case 4 -> Care.manageCareActions(conn, scanner);
                    case 5 -> listAllTables(conn);
                    case 6 -> {
                        System.out.println("Viso gero!");
                        return;
                    }
                    default -> System.out.println("Neteisingas pasirinkimas, bandykite dar karta.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void listAllTables(Connection conn) throws SQLException {
        DatabaseUtils.listAllTables(conn);
    }
}
