package vn.libman.module;

/** Bibliographic information for a document listed on an import invoice. */
public class Document8 {
  private final long documentId;
  private final String title;
  private final String publisher;
  private final String publishYear;
  private final String description;

  public Document8(long documentId, String title, String publisher, String publishYear, String description) {
    this.documentId = documentId;
    this.title = title;
    this.publisher = publisher;
    this.publishYear = publishYear;
    this.description = description;
  }

  public long documentId() { return documentId; }
  public String title() { return title; }
  public String publisher() { return publisher; }
  public String publishYear() { return publishYear; }
  public String description() { return description; }
  public long getDocumentId() { return documentId; }
  public String getTitle() { return title; }
  public String getPublisher() { return publisher; }
  public String getPublishYear() { return publishYear; }
  public String getDescription() { return description; }
}
