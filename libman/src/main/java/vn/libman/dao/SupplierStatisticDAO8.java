package vn.libman.dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import vn.libman.module.SupplierStatistic8;


public final class SupplierStatisticDAO8 extends DAO8 {
  public SupplierStatisticDAO8(java.sql.Connection connection) { super(connection); }

  public List<SupplierStatistic8> getSupplierStatistic(LocalDate startDate, LocalDate endDate) {
    String sql = "{call sp_supplier_statistic(?,?)}";
    try (CallableStatement statement = con.prepareCall(sql)) {
      statement.setDate(1, java.sql.Date.valueOf(startDate));
      statement.setDate(2, java.sql.Date.valueOf(endDate));
      try (ResultSet result = statement.executeQuery()) {
        List<SupplierStatistic8> statistics = new ArrayList<>();
        while (result.next()) {
          statistics.add(new SupplierStatistic8(result.getLong("supplier_id"),
              result.getString("supplier_name"), result.getString("address"),
              result.getString("phone"), result.getString("email"),
              result.getString("description"), result.getLong("invoice_count"),
              result.getLong("total_quantity"), result.getBigDecimal("total_amount")));
        }
        return statistics;
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể thống kê nhà cung cấp", exception);
    }
  }
}