import java.sql.Connection;
import java.sql.SQLException;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        try (Connection conn = DatabaseConnection.connect()) {
            Scanner scanner = new Scanner(System.in);
            while (true) {
                System.out.println("=== Aquarium Management System ===");
                System.out.println("1. List caretakers for an aquarium");
                System.out.println("2. Exit");
                System.out.print("Enter your choice: ");
                int choice = scanner.nextInt();
                if (choice == 1) {
                    System.out.print("Enter Aquarium ID: ");
                    int aquariumId = scanner.nextInt();
                    Caretaker.listCaretakers(conn, aquariumId);
                } else if (choice == 2) {
                    break;
                } else {
                    System.out.println("Invalid choice.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
