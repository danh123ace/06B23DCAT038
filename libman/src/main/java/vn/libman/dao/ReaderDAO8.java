package vn.libman.dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import vn.libman.module.Reader8;

/** Reader profile DAO using MariaDB stored procedures. */
public final class ReaderDAO8 extends DAO8 {
  public ReaderDAO8(java.sql.Connection connection) { super(connection); }

  public Reader8 getReaderProfile(long readerId) {
    String sql = "{call sp_reader_profile(?)}";
    try (CallableStatement statement = con.prepareCall(sql)) {
      statement.setLong(1, readerId);
      try (ResultSet result = statement.executeQuery()) {
        if (!result.next()) throw new IllegalStateException("Không tìm thấy hồ sơ bạn đọc");
        return new Reader8(result.getLong("reader_id"), result.getLong("user_id"),
            result.getString("full_name"), result.getObject("dob", LocalDate.class),
            result.getString("address"), result.getString("email"), result.getString("phone"));
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể lấy hồ sơ bạn đọc", exception);
    }
  }

  public void updateContactInfo(long readerId, String address, String email, String phone) {
    try (CallableStatement statement = con.prepareCall("{call sp_reader_update_contact(?,?,?,?)}")) {
      statement.setLong(1, readerId);
      statement.setString(2, address);
      statement.setString(3, email);
      statement.setString(4, phone);
      statement.execute();
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể cập nhật thông tin liên hệ", exception);
    }
  }
}