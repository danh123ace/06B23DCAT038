package vn.libman.module;

import java.time.LocalDate;


public class Manager8 extends User8 {
  private final long managerId;

  public Manager8(long managerId, long userId, String fullName, LocalDate dob,
                  String address, String email, String phone) {
    super(userId, fullName, dob, address, email, phone);
    this.managerId = managerId;
  }

  public long managerId() { return managerId; }
  public long getManagerId() { return managerId; }
}
