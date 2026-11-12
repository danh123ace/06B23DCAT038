package vn.libman.module;


public class Supplier8 {
  private final long supplierId;
  private final String name;
  private final String address;
  private final String phone;
  private final String email;
  private final String description;

  public Supplier8(long supplierId, String name, String address, String phone, String email, String description) {
    this.supplierId = supplierId;
    this.name = name;
    this.address = address;
    this.phone = phone;
    this.email = email;
    this.description = description;
  }

  public long supplierId() { return supplierId; }
  public String name() { return name; }
  public String address() { return address; }
  public String phone() { return phone; }
  public String email() { return email; }
  public String description() { return description; }
  public long getSupplierId() { return supplierId; }
  public String getName() { return name; }
  public String getAddress() { return address; }
  public String getPhone() { return phone; }
  public String getEmail() { return email; }
  public String getDescription() { return description; }
}
