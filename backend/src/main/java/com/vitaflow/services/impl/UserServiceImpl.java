package com.vitaflow.backend.services.impl;

import com.vitaflow.backend.entities.User;
import com.vitaflow.backend.repositories.UserRepo;
import com.vitaflow.backend.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepo userRepo;

    @Override
    public User saveUser(User user) {
        return userRepo.save(user);
    }

    @Override
    public User updateUser(String userId, User updatedUser) {
        User existingUser = userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        existingUser.setName(updatedUser.getName());
        existingUser.setEmail(updatedUser.getEmail());
        existingUser.setPassword(updatedUser.getPassword());
        existingUser.setAbout(updatedUser.getAbout());
        existingUser.setProfilePic(updatedUser.getProfilePic());
        existingUser.setPhoneNumber(updatedUser.getPhoneNumber());
        existingUser.setEnabled(updatedUser.isEnabled());
        existingUser.setEmailVerified(updatedUser.isEmailVerified());
        existingUser.setPhoneVerified(updatedUser.isPhoneVerified());
        existingUser.setProvider(updatedUser.getProvider());

        return userRepo.save(existingUser);
    }

    @Override
    public User getUserById(String userId) {
        return userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public List<User> getAllUsers() {
        return userRepo.findAll();
    }

    @Override
    public void deleteUser(String userId) {
        if (!userRepo.existsById(userId)) {
            throw new RuntimeException("User is not found");
        }
        userRepo.deleteById(userId);
    }
}
