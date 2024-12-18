import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    public static Connection connect() throws SQLException {
        String url = "jdbc:postgresql://localhost:5432/aquarium_db";
        String user = "justas";
        String password = "justas";
        return DriverManager.getConnection(url, user, password);
    }
}
