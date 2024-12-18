import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Caretaker {
    public static void listCaretakers(Connection conn, int aquariumId) throws SQLException {
        String query = """
            SELECT p.Vardas, p.Pavarde, p.Kvalifikacija, pr.Pradzia
            FROM judr0384.Priziuretojas p
            JOIN judr0384.Prieziura pr ON p.ID = pr.PriziuretojoID
            WHERE pr.AkvariumoID = ? AND pr.Pabaiga IS NULL;
            """;

        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, aquariumId);
            ResultSet rs = stmt.executeQuery();

            System.out.println("+-----------------+-----------------+-----------------+-----------------+");
            System.out.println("| Caretaker       | Qualification  | Start Date      |");
            System.out.println("+-----------------+-----------------+-----------------+");

            while (rs.next()) {
                System.out.printf("| %-15s | %-15s | %-15s |\n",
                        rs.getString("Vardas") + " " + rs.getString("Pavarde"),
                        rs.getString("Kvalifikacija"),
                        rs.getDate("Pradzia"));
            }

            System.out.println("+-----------------+-----------------+-----------------+");
        }
    }
}
