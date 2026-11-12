package vn.libman.module;

import java.math.BigDecimal;

/** Document line recorded on an ImportInvoice8; the document is modeled as Document8. */
public record ImportInvoiceDetail8(long importInvoiceDetailId, long importInvoiceId,
                                   Document8 document, int quantity, BigDecimal unitPrice, String note) {
  public BigDecimal lineAmount() { return unitPrice.multiply(BigDecimal.valueOf(quantity)); }
}
