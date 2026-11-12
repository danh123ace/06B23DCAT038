package vn.libman.dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Optional;
import vn.libman.module.ReaderCard8;
public final class ReaderCardDAO8 extends DAO8 {
  public ReaderCardDAO8(java.sql.Connection connection) { super(connection); }

  public Optional<ReaderCard8> getCurrentCard(long readerId) {
    try (CallableStatement statement = con.prepareCall("{call sp_reader_current_card(?)}")) {
      statement.setLong(1, readerId);
      try (ResultSet result = statement.executeQuery()) {
        if (!result.next()) return Optional.empty();
        return Optional.of(map(result));
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể lấy trạng thái thẻ bạn đọc", exception);
    }
  }

  public void markExpired(long cardId) {
    try (CallableStatement statement = con.prepareCall("{call sp_reader_card_mark_expired(?)}")) {
      statement.setLong(1, cardId);
      statement.execute();
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể cập nhật thẻ hết hạn", exception);
    }
  }
  public ReaderCard8 createCard(long readerId, String cardType) {
    try (CallableStatement statement = con.prepareCall("{call sp_reader_card_create(?,?)}")) {
      statement.setLong(1, readerId);
      statement.setString(2, cardType);
      try (ResultSet result = statement.executeQuery()) {
        if (!result.next()) throw new IllegalStateException("Không nhận được thẻ vừa tạo");
        return map(result);
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể tạo thẻ bạn đọc", exception);
    }
  }

  private static ReaderCard8 map(ResultSet result) throws SQLException {
    return new ReaderCard8(result.getLong("card_id"), result.getLong("reader_id"),
        result.getString("card_code"), result.getString("card_type"),
        result.getObject("issue_date", LocalDate.class),
        result.getObject("expiry_date", LocalDate.class),
        result.getString("status"), result.getString("block_reason"));
  }
}