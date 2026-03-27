package com.vitaflow.controllers;

import com.vitaflow.entities.user.Doctor;
import com.vitaflow.entities.user.Donor;
import com.vitaflow.entities.user.Rider;
import com.vitaflow.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

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

    @PostMapping("/send-email-otp")
    public ResponseEntity<?> sendEmailOtp(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");
        try {
            boolean sent = userService.sendEmailOtp(email);
            return ResponseEntity.ok(Map.of("message", "OTP sent to email successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody Map<String, String> payload) {
        String phoneNumber = payload.get("phoneNumber");
        String otp = payload.get("otp");
        try {
            Map<String, Object> response = userService.verifyOtp(phoneNumber, otp);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/verify-email-otp")
    public ResponseEntity<?> verifyEmailOtp(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");
        String otp = payload.get("otp");
        try {
            Map<String, Object> response = userService.verifyEmailOtp(email, otp);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/login-with-password")
    public ResponseEntity<?> loginWithPassword(@RequestBody Map<String, String> payload) {
        String phoneNumber = payload.get("phoneNumber");
        String password = payload.get("password");
        try {
            Map<String, Object> response = userService.loginWithPassword(phoneNumber, password);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> payload) {
        String phoneNumber = payload.get("phoneNumber");
        String otp       = payload.get("otp");
        String newPassword = payload.get("newPassword");
        // First validate OTP
        try {
            userService.verifyOtp(phoneNumber, otp);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", "Invalid OTP: " + e.getMessage()));
        }
        boolean updated = userService.resetPassword(phoneNumber, newPassword);
        if (updated) {
            return ResponseEntity.ok(Map.of("message", "Password reset successfully"));
        } else {
            return ResponseEntity.badRequest().body(Map.of("message", "No account found with this phone number"));
        }
    }

    @PostMapping("/reset-password-email")
    public ResponseEntity<?> resetPasswordEmail(@RequestBody Map<String, String> payload) {
        String email = payload.get("email");
        String otp       = payload.get("otp");
        String newPassword = payload.get("newPassword");
        // First validate OTP
        try {
            userService.verifyEmailOtp(email, otp);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", "Invalid OTP: " + e.getMessage()));
        }
        boolean updated = userService.resetPasswordByEmail(email, newPassword);
        if (updated) {
            return ResponseEntity.ok(Map.of("message", "Password reset successfully"));
        } else {
            return ResponseEntity.badRequest().body(Map.of("message", "No account found with this email"));
        }
    }

    // Role Specific Registration
    @PostMapping("/register/doctor")
    public Map<String, Object> registerDoctor(@RequestBody Doctor doctor) {
        Doctor savedDoctor = userService.saveDoctor(doctor);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("token", "dummy-token");
        response.put("user", savedDoctor);
        return response;
    }

    @PostMapping("/register/donor")
    public Map<String, Object> registerDonor(@RequestBody Donor donor) {
        Donor savedDonor = userService.saveDonor(donor);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("token", "dummy-token");
        response.put("user", savedDonor);
        return response;
    }

    @PostMapping("/register/rider")
    public Map<String, Object> registerRider(@RequestBody Rider rider) {
        Rider savedRider = userService.saveRider(rider);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("token", "dummy-token");
        response.put("user", savedRider);
        return response;
    }

    @Autowired
    private tools.jackson.databind.ObjectMapper mapper;

    // Generic Complete Profile (Restored for Frontend Compatibility)
    @PostMapping("/complete-profile")
    public ResponseEntity<?> completeProfile(@RequestBody Map<String, Object> payload) {
        System.out.println("Processing complete-profile with payload: " + payload);
        String roleStr = (String) payload.get("role");
        if (roleStr == null) {
             return ResponseEntity.badRequest().body(Map.of("message", "Role is required"));
        }
        
        try {
            com.vitaflow.entities.Role role = com.vitaflow.entities.Role.valueOf(roleStr);
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            
            switch (role) {
                case DOCTOR:
                    Doctor doctor = mapper.convertValue(payload, Doctor.class);
                    System.out.println("Mapped Doctor Ordinate: " + (doctor.getOrdinate() != null ? doctor.getOrdinate().getLatitude() : "null"));
                    response.put("user", userService.saveDoctor(doctor));
                    break;
                case DONOR:
                     Donor donor = mapper.convertValue(payload, Donor.class);
                     System.out.println("Mapped Donor Ordinate: " + (donor.getOrdinate() != null ? donor.getOrdinate().getLatitude() : "null"));
                     response.put("user", userService.saveDonor(donor));
                     break;
                 case RIDER:
                     Rider rider = mapper.convertValue(payload, Rider.class);
                     System.out.println("Mapped Rider Ordinate: " + (rider.getOrdinate() != null ? rider.getOrdinate().getLatitude() : "null"));
                     response.put("user", userService.saveRider(rider));
                     break;
                default:
                    return ResponseEntity.badRequest().body(Map.of("message", "Invalid role for registration"));
            }
            return ResponseEntity.ok(response);
            
        } catch (IllegalArgumentException e) {
             return ResponseEntity.badRequest().body(Map.of("message", "Invalid role: " + roleStr));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("message", "Error saving user: " + e.getMessage()));
        }
    }
    
    // Get User By ID (Role Specific)
    @GetMapping("/doctor/{userId}")
    public Doctor getDoctor(@PathVariable String userId) {
        return userService.getDoctorById(userId);
    }

    @GetMapping("/donor/{userId}")
    public Donor getDonor(@PathVariable String userId) {
        return userService.getDonorById(userId);
    }

    @GetMapping("/rider/{userId}")
    public Rider getRider(@PathVariable String userId) {
        return userService.getRiderById(userId);
    }

    @PutMapping("/location")
    public ResponseEntity<?> updateLocation(@RequestBody Map<String, Object> payload) {
        String phoneNumber = (String) payload.get("phoneNumber");
        Double latitude = ((Number) payload.get("latitude")).doubleValue();
        Double longitude = ((Number) payload.get("longitude")).doubleValue();

        if (phoneNumber == null || latitude == null || longitude == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "Phone number, latitude, and longitude are required"));
        }

        com.vitaflow.payload.LocationDTO location = new com.vitaflow.payload.LocationDTO(latitude, longitude);
        boolean updated = userService.updateUserLocation(phoneNumber, location);

        if (updated) {
            return ResponseEntity.ok(Map.of("message", "Location updated successfully"));
        } else {
            return ResponseEntity.badRequest().body(Map.of("message", "User not found"));
        }
    }

    @GetMapping("/exists/{phoneNumber}")
    public ResponseEntity<Boolean> existsByPhoneNumber(@PathVariable String phoneNumber) {
        System.out.println("Checking existence for phone: " + phoneNumber);
        return ResponseEntity.ok(userService.existsByPhoneNumber(phoneNumber));
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> payload) {
        String phoneNumber = payload.get("phoneNumber");
        String oldPassword = payload.get("oldPassword");
        String newPassword = payload.get("newPassword");

        if (phoneNumber == null || oldPassword == null || newPassword == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "Phone number, old password, and new password are required"));
        }

        boolean updated = userService.changePassword(phoneNumber, oldPassword, newPassword);
        if (updated) {
            return ResponseEntity.ok(Map.of("message", "Password changed successfully"));
        } else {
            return ResponseEntity.badRequest().body(Map.of("message", "Incorrect old password or user not found"));
        }
    }
}
