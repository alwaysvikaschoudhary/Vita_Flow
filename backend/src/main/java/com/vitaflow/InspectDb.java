import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.DatabaseMetaData;

public class InspectDb {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/vitaflow";
        String user = "postgres";
        String password = "58255825";

        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            DatabaseMetaData dbm = conn.getMetaData();
            ResultSet cols = dbm.getColumns(null, null, "blood_requests", "%");
            while (cols.next()) {
                System.out.println("Column: " + cols.getString("COLUMN_NAME") + " Type: " + cols.getString("TYPE_NAME"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
