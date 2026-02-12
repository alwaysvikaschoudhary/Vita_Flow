package com.vitaflow.controllers;

import com.vitaflow.entities.User;
import com.vitaflow.payload.AuthResponse;
import com.vitaflow.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    // Auth - OTP
    @PostMapping("/send-otp")
    public ResponseEntity<?> sendOtp(@RequestBody Map<String, String> payload) {
        String phoneNumber = payload.get("phoneNumber");
        boolean sent = userService.sendOtp(phoneNumber);
        if (sent) {
            return ResponseEntity.ok(Map.of("message", "OTP sent successfully"));
        } else {
            return ResponseEntity.badRequest().body(Map.of("message", "Failed to send OTP"));
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody Map<String, String> payload) {
        String phoneNumber = payload.get("phoneNumber");
        String otp = payload.get("otp");
        try {
            AuthResponse response = userService.verifyOtp(phoneNumber, otp);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @Autowired
    private com.vitaflow.util.JwtUtil jwtUtil;

    // Capture User Details after OTP verification (if new user)
    @PostMapping("/complete-profile")
    public AuthResponse completeProfile(@RequestBody User user) {
        User savedUser = userService.saveUser(user);
        String token = jwtUtil.generateToken(savedUser.getPhoneNumber(), savedUser.getRole().name());
        return AuthResponse.builder()
                .token(token)
                .user(savedUser)
                .build();
    }


    // READ BY ID
    @GetMapping("/{userId}")
    public User getUser(@PathVariable String userId) {
        return userService.getUserById(userId);
    }

    // READ ALL
    @GetMapping
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }

    // UPDATE
    @PutMapping("/{userId}")
    public User updateUser(
            @PathVariable String userId,
            @RequestBody User user
    ) {
        return userService.updateUser(userId, user);
    }

    // DELETE
    @DeleteMapping("/{userId}")
    public String deleteUser(@PathVariable String userId) {
        userService.deleteUser(userId);
        return "User deleted successfully";
    }
}
