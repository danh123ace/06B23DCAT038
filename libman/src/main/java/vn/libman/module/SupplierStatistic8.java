package vn.libman.module;

import java.math.BigDecimal;

/** Report projection specializing Supplier8 with import totals. */
public final class SupplierStatistic8 extends Supplier8 {
  private final long invoiceCount;
  private final long totalQuantity;
  private final BigDecimal totalAmount;

  public SupplierStatistic8(long supplierId, String name, String address, String phone,
                            String email, String description, long invoiceCount,
                            long totalQuantity, BigDecimal totalAmount) {
    super(supplierId, name, address, phone, email, description);
    this.invoiceCount = invoiceCount;
    this.totalQuantity = totalQuantity;
    this.totalAmount = totalAmount;
  }

  public long invoiceCount() { return invoiceCount; }
  public long totalQuantity() { return totalQuantity; }
  public BigDecimal totalAmount() { return totalAmount; }
  public long getInvoiceCount() { return invoiceCount; }
  public long getTotalQuantity() { return totalQuantity; }
  public BigDecimal getTotalAmount() { return totalAmount; }
}
