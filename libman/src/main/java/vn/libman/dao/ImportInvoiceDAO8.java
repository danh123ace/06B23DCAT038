package vn.libman.dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import vn.libman.module.ImportInvoice8;


public final class ImportInvoiceDAO8 extends DAO8 {
  public ImportInvoiceDAO8(java.sql.Connection connection) { super(connection); }

  public List<ImportInvoice8> getInvoiceBySupplier(
      long supplierId, LocalDate startDate, LocalDate endDate) {
    try (CallableStatement statement = con.prepareCall("{call sp_import_invoice_by_supplier(?,?,?)}")) {
      statement.setLong(1, supplierId);
      statement.setDate(2, java.sql.Date.valueOf(startDate));
      statement.setDate(3, java.sql.Date.valueOf(endDate));
      try (ResultSet result = statement.executeQuery()) {
        List<ImportInvoice8> invoices = new ArrayList<>();
        while (result.next()) {
          invoices.add(new ImportInvoice8(result.getLong("invoice_id"),
              result.getLong("supplier_id"), result.getLong("librarian_id"),
              result.getString("invoice_code"),
              result.getDate("imported_at").toLocalDate(),
              result.getString("note"), result.getLong("total_quantity"),
              result.getBigDecimal("total_amount"), List.of()));
        }
        return invoices;
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể lấy danh sách hóa đơn nhập", exception);
    }
  }
}