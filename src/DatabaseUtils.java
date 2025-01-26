import java.sql.*;
import java.util.InputMismatchException;
import java.util.Scanner;

public class DatabaseUtils {

    public static void listAllTables(Connection conn) throws SQLException {
        String tableQuery = """
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = 'public'
               OR schemaname = 'judr0384';
            """;

        try (Statement stmt = conn.createStatement();
             ResultSet tables = stmt.executeQuery(tableQuery)) {

            System.out.println("\n--- Visos lenteles ir ju duomenys: ---\n");

            while (tables.next()) {
                String tableName = tables.getString("tablename");

                System.out.printf("Table: %s\n", tableName);
                printTableContents(conn, tableName);
            }
        }
    }

    private static void printTableContents(Connection conn, String tableName) {
        String query = "SELECT * FROM " + tableName;

        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();

            // Print column headers
            for (int i = 1; i <= columnCount; i++) {
                System.out.printf("%-20s", metaData.getColumnName(i));
            }
            System.out.println();
            System.out.println("-".repeat(columnCount * 20));

            // Print rows
            while (rs.next()) {
                for (int i = 1; i <= columnCount; i++) {
                    System.out.printf("%-20s", rs.getString(i));
                }
                System.out.println();
            }

            System.out.println();
        } catch (SQLException e) {
            System.out.printf("Nepavyko gauti duomenu is lenteles %s. Klaida: %s%n", tableName, e.getMessage());
        }
    }

    // List all rows for a specific table
    public static void listTable(Connection conn, String query, String tableName) {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();

            System.out.println("\n--- " + tableName + " ---");
            for (int i = 1; i <= columnCount; i++) {
                System.out.printf("%-20s", metaData.getColumnName(i));
            }
            System.out.println();
            System.out.println("-".repeat(columnCount * 20));

            while (rs.next()) {
                for (int i = 1; i <= columnCount; i++) {
                    System.out.printf("%-20s", rs.getString(i));
                }
                System.out.println();
            }

        } catch (SQLException e) {
            handleError(e, "Klaida rodant lentele: " + tableName);
        }
    }

    public static boolean executeUpdate(Connection conn, String query, Object... params) {
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            for (int i = 0; i < params.length; i++) {
                stmt.setObject(i + 1, params[i]);
            }
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            handleError(e, "Nepavyko atnaujinti.");
            return false;
        }
    }

    public static void handleError(Exception e, String userMessage) {
        System.err.println(userMessage);
        System.err.println("Klaida: " + e.getMessage());
    }

    public static int getIntInput(Scanner scanner) {
        int input = -1;
        while (true) {
            try {
                input = scanner.nextInt();
                break;  // Exit the loop if valid input is entered
            } catch (InputMismatchException e) {
                System.out.println("Neteisingas skaicius, bandykite dar.");
                scanner.nextLine();  // Clear the invalid input
            }
        }
        return input;
    }

    public static double getDoubleInput(Scanner scanner) {
        double input = -1;
        while (true) {
            try {
                input = scanner.nextDouble();
                break;  // Exit the loop if valid input is entered
            } catch (InputMismatchException e) {
                System.out.println("Neteisingas skaicius, bandykite dar.");
                scanner.nextLine();  // Clear the invalid input
            }
        }
        return input;
    }


    public static boolean getBooleanInput(Scanner scanner) {
        boolean input = false;
        while (true) {
            try {
                input = scanner.nextBoolean();
                break;  // Exit the loop if valid input is entered
            } catch (InputMismatchException e) {
                System.out.println("Neteisingas atsakymas, bandykite dar (true/false).");
                scanner.nextLine();  // Clear the invalid input
            }
        }
        return input;
    }
}
