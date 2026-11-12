package vn.libman.module;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;


public record ImportInvoice8(long importInvoiceId, long supplierId, long librarianId,
                             String invoiceCode, LocalDate importDate, String note,
                             long totalQuantity, BigDecimal totalAmount,
                             List<ImportInvoiceDetail8> details) {
  public ImportInvoice8 { details = List.copyOf(details); }
}
