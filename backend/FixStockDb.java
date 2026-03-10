import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class FixStockDb {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/vitaflow";
        String user = "postgres"; // Adjust if needed
        String password = "admin"; // Adjust if needed

        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {
            
            System.out.println("Connected to database. Fixing blood_stocks sequence...");
            stmt.executeUpdate("CREATE SEQUENCE IF NOT EXISTS blood_stocks_id_seq;");
            stmt.executeUpdate("ALTER TABLE blood_stocks ALTER COLUMN id SET DEFAULT nextval('blood_stocks_id_seq');");
            System.out.println("Done!");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
