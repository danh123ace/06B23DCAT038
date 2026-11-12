package vn.libman.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public abstract class DAO8 {
  protected final Connection con;

  protected DAO8(Connection connection) {
    if (connection == null) throw new IllegalArgumentException("connection is required");
    this.con = connection;
  }

  public static Connection openConnection() throws SQLException {
    try {
      Class.forName("org.mariadb.jdbc.Driver");
    } catch (ClassNotFoundException exception) {
      throw new SQLException("MariaDB JDBC driver is missing from the web application", exception);
    }
    String url = System.getenv().getOrDefault(
        "LIBMAN_JDBC_URL", "jdbc:mariadb://127.0.0.1:3306/libman");
    String user = System.getenv().getOrDefault("LIBMAN_DB_USER", "root");
    String password = System.getenv().getOrDefault("LIBMAN_DB_PASSWORD", "");
    return DriverManager.getConnection(url, user, password);
  }
}
