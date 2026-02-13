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
                    response.put("user", userService.saveDoctor(doctor));
                    break;
                case DONOR:
                     Donor donor = mapper.convertValue(payload, Donor.class);
                     response.put("user", userService.saveDonor(donor));
                     break;
                 case RIDER:
                     Rider rider = mapper.convertValue(payload, Rider.class);
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
}
