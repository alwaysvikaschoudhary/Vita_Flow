package com.vitaflow.services;

import com.vitaflow.entities.User;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface UserService {

    User saveUser(User user);
    User updateUser(String userId, User user);
    User getUserById(String userId);
    List<User> getAllUsers();
    void deleteUser(String userId);

    // Auth
    com.vitaflow.payload.AuthResponse verifyOtp(String phoneNumber, String otp);
    boolean sendOtp(String phoneNumber);

}


