package vn.libman.dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public final class ManagerDAO8 extends DAO8 {
  public ManagerDAO8(java.sql.Connection connection) { super(connection); }

  public boolean isActiveManager(long managerId) {
    try (CallableStatement statement = con.prepareCall("{call sp_manager_is_active(?)}")) {
      statement.setLong(1, managerId);
      try (ResultSet result = statement.executeQuery()) {
        return result.next() && result.getBoolean("is_active");
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể xác thực quản lý", exception);
    }
  }
}