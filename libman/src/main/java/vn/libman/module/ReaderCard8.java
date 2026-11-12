package vn.libman.module;

import java.time.LocalDate;

public class ReaderCard8 {
  private final long readerCardId;
  private final long readerId;
  private final String cardCode;
  private final String cardType;
  private final LocalDate issueDate;
  private final LocalDate expiryDate;
  private final String status;
  private final String lockReason;

  public ReaderCard8(long readerCardId, long readerId, String cardCode, String cardType,
                     LocalDate issueDate, LocalDate expiryDate, String status, String lockReason) {
    this.readerCardId = readerCardId;
    this.readerId = readerId;
    this.cardCode = cardCode;
    this.cardType = cardType;
    this.issueDate = issueDate;
    this.expiryDate = expiryDate;
    this.status = status;
    this.lockReason = lockReason;
  }

  public long readerCardId() { return readerCardId; }
  public long readerId() { return readerId; }
  public String cardCode() { return cardCode; }
  public String cardType() { return cardType; }
  public LocalDate issueDate() { return issueDate; }
  public LocalDate expiryDate() { return expiryDate; }
  public String status() { return status; }
  public String lockReason() { return lockReason; }
  public long getReaderCardId() { return readerCardId; }
  public long getReaderId() { return readerId; }
  public String getCardCode() { return cardCode; }
  public String getCardType() { return cardType; }
  public LocalDate getIssueDate() { return issueDate; }
  public LocalDate getExpiryDate() { return expiryDate; }
  public String getStatus() { return status; }
  public String getLockReason() { return lockReason; }
}
