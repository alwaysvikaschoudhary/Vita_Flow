import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class FixDb {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/vitaflow";
        String user = "postgres";
        String password = "58255825";

        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {
             
            System.out.println("Connected to database. Attempting to add missing columns...");
            
            try {
                stmt.execute("ALTER TABLE blood_requests ADD COLUMN delivery_otp_attempts int4;");
                System.out.println("Added delivery_otp_attempts successfully.");
            } catch (Exception e) {
                System.out.println("delivery_otp_attempts might already exist: " + e.getMessage());
            }

            try {
                stmt.execute("ALTER TABLE blood_requests ADD COLUMN delivery_otp varchar(255);");
                System.out.println("Added delivery_otp successfully.");
            } catch (Exception e) {
                System.out.println("delivery_otp might already exist: " + e.getMessage());
            }
            
            System.out.println("Done fixing DB.");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
