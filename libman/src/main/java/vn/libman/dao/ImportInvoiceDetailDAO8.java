package vn.libman.dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import vn.libman.module.Document8;
import vn.libman.module.ImportInvoiceDetail8;

/** Import invoice line DAO implemented with a stored procedure. */
public final class ImportInvoiceDetailDAO8 extends DAO8 {
  public ImportInvoiceDetailDAO8(java.sql.Connection connection) { super(connection); }

  public List<ImportInvoiceDetail8> getDetailByImportInvoice(long invoiceId) {
    try (CallableStatement statement = con.prepareCall("{call sp_import_invoice_detail(?)}")) {
      statement.setLong(1, invoiceId);
      try (ResultSet result = statement.executeQuery()) {
        List<ImportInvoiceDetail8> details = new ArrayList<>();
        while (result.next()) {
          Document8 document = new Document8(result.getLong("document_id"),
              result.getString("title"), result.getString("publisher"),
              result.getString("publication_year"), result.getString("description"));
          details.add(new ImportInvoiceDetail8(result.getLong("detail_id"), invoiceId,
              document, result.getInt("quantity"), result.getBigDecimal("unit_price"),
              result.getString("note")));
        }
        return details;
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Không thể lấy chi tiết hóa đơn nhập", exception);
    }
  }
}