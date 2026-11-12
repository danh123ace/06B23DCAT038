package vn.libman.module;

import java.time.LocalDate;

/** Base entity shared by Reader8, Librarian8 and Manager8, following the analysis model. */
public abstract class User8 {
  private final long userId;
  private final String fullName;
  private final LocalDate dob;
  private final String address;
  private final String email;
  private final String phone;

  protected User8(long userId, String fullName, LocalDate dob, String address, String email, String phone) {
    this.userId = userId;
    this.fullName = fullName;
    this.dob = dob;
    this.address = address;
    this.email = email;
    this.phone = phone;
  }

  public long userId() { return userId; }
  public String fullName() { return fullName; }
  public LocalDate dob() { return dob; }
  public String address() { return address; }
  public String email() { return email; }
  public String phone() { return phone; }

  public long getUserId() { return userId; }
  public String getFullName() { return fullName; }
  public LocalDate getDob() { return dob; }
  public String getAddress() { return address; }
  public String getEmail() { return email; }
  public String getPhone() { return phone; }
}
