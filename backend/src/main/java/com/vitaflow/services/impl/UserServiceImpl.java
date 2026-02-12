package com.vitaflow.services.impl;

import com.vitaflow.entities.User;
import com.vitaflow.payload.AuthResponse;
import com.vitaflow.repositories.UserRepository;
import com.vitaflow.services.OtpService;
import com.vitaflow.services.UserService;
import com.vitaflow.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private OtpService otpService;

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public boolean sendOtp(String phoneNumber) {
        otpService.generateOtp(phoneNumber);
        return true;
    }

    @Override
    public AuthResponse verifyOtp(String phoneNumber, String otp) {
        if (!otpService.validateOtp(phoneNumber, otp)) {
            throw new RuntimeException("Invalid OTP");
        }

        // Check if user exists
        User user = userRepository.findByPhoneNumber(phoneNumber)
                .orElse(null);

        // If user is new, return null user but valid token (or special flag)
        // For simplicity, we'll create a temporary placeholder or handle NEW_USER logic in frontend
        // Here, we will Return AuthResponse with User=null if new, User=obj if existing
        
        String token = "";
        if (user != null) {
             token = jwtUtil.generateToken(user.getPhoneNumber(), user.getRole().name());
        } else {
             // For new users, we might issue a temporary registration token or just return null flag
             // Let's assume frontend proceeds to registration screen
             return AuthResponse.builder().token(null).user(null).build();
        }

        return AuthResponse.builder()
                .token(token)
                .user(user)
                .build();
    }
    
    // Used for completing registration after OTP
    @Override
    public User saveUser(User user) {
        if (userRepository.findByPhoneNumber(user.getPhoneNumber()).isPresent()) {
             // Update existing if needed, or throw error
             // For now, assume this is for completing profile
        } else {
            user.setUserId(UUID.randomUUID().toString());
        }
        return userRepository.save(user);
    }


    @Override
    public User updateUser(String userId, User updatedUser) {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        existingUser.setName(updatedUser.getName());
        existingUser.setEmail(updatedUser.getEmail());
        existingUser.setAbout(updatedUser.getAbout());
        existingUser.setProfilePic(updatedUser.getProfilePic());
        existingUser.setPhoneNumber(updatedUser.getPhoneNumber());
        existingUser.setEmailVerified(updatedUser.getEmailVerified() != null ? updatedUser.getEmailVerified() : existingUser.getEmailVerified());
        existingUser.setRole(updatedUser.getRole());

        // Update Role Specific Fields if present
        if(updatedUser.getBloodGroup() != null) existingUser.setBloodGroup(updatedUser.getBloodGroup());
        if(updatedUser.getDob() != null) existingUser.setDob(updatedUser.getDob());
        if(updatedUser.getHospitalName() != null) existingUser.setHospitalName(updatedUser.getHospitalName());
        if(updatedUser.getSpecialization() != null) existingUser.setSpecialization(updatedUser.getSpecialization());
        if(updatedUser.getBikeNumber() != null) existingUser.setBikeNumber(updatedUser.getBikeNumber());


        return userRepository.save(existingUser);
    }

    @Override
    public User getUserById(String userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Override
    public void deleteUser(String userId) {
        if (!userRepository.existsById(userId)) {
            throw new RuntimeException("User is not found");
        }
        userRepository.deleteById(userId);
    }
}
