package vn.libman.module;

import java.time.LocalDate;

/** Library employee who issues loans, receives returns and creates import invoices. */
public class Librarian8 extends User8 {
  private final long librarianId;
  private final String department;

  public Librarian8(long librarianId, long userId, String fullName, LocalDate dob,
                    String address, String email, String phone, String department) {
    super(userId, fullName, dob, address, email, phone);
    this.librarianId = librarianId;
    this.department = department;
  }

  public long librarianId() { return librarianId; }
  public String department() { return department; }
  public long getLibrarianId() { return librarianId; }
  public String getDepartment() { return department; }
}
