package vn.libman.dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;


public final class AccountDAO8 extends DAO8 {
  public AccountDAO8(java.sql.Connection connection) { super(connection); }

  public Optional<LoginAccount8> getByUsername(String username) throws SQLException {
    try (CallableStatement statement = con.prepareCall("{call sp_account_by_username(?)}")) {
      statement.setString(1, username);
      try (ResultSet result = statement.executeQuery()) {
        if (!result.next()) return Optional.empty();
        long readerValue = result.getLong("reader_id");
        Long readerId = result.wasNull() ? null : readerValue;
        long managerValue = result.getLong("manager_id");
        Long managerId = result.wasNull() ? null : managerValue;
        return Optional.of(new LoginAccount8(result.getLong("user_id"),
            result.getString("username"), result.getString("full_name"),
            result.getString("password_hash"), result.getString("role"), readerId, managerId));
      }
    }
  }
}
