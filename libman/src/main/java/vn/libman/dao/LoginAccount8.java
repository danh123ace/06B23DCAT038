package vn.libman.dao;


public record LoginAccount8(long userId, String username, String fullName, String passwordHash,
                            String role, Long readerId, Long managerId) {}
