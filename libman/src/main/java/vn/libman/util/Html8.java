package vn.libman.util;

/** Small JSP presentation helper for safe HTML output. */
public final class Html8 {
  private Html8() {}
  public static String escape(Object value) {
    if (value == null) return "";
    return value.toString().replace("&", "&amp;").replace("<", "&lt;")
        .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
  }
}
