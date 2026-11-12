package vn.libman.module;

import java.time.LocalDate;

/** Library reader; inherits the personal profile from User8. */
public class Reader8 extends User8 {
  private final long readerId;

  public Reader8(long readerId, long userId, String fullName, LocalDate dob,
                 String address, String email, String phone) {
    super(userId, fullName, dob, address, email, phone);
    this.readerId = readerId;
  }

  public long readerId() { return readerId; }
  public long getReaderId() { return readerId; }
}
