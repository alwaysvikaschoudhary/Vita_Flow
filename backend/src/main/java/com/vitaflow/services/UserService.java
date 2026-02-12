package com.vitaflow.backend.services;

import com.vitaflow.backend.entities.User;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface UserService {

    User saveUser(User user);
    User updateUser(String userId, User user);
    User getUserById(String userId);
    List<User> getAllUsers();
    void deleteUser(String userId);

}
