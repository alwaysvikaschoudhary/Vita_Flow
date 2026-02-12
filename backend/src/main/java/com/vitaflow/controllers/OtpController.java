package com.vitaflow.backend.controllers;

import com.vitaflow.backend.services.OtpService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class OtpController {

    private final OtpService otpService;

    public OtpController(OtpService otpService) {
        this.otpService = otpService;
    }

    // STEP 1: send OTP
    @PostMapping("/login")
    public ResponseEntity<String> sendOtp(@RequestParam String phone) {
        otpService.sendOtp(phone);
        return ResponseEntity.ok("OTP sent");
    }

    // STEP 2: verify OTP
    @PostMapping("/verify")
    public ResponseEntity<String> verifyOtp(
            @RequestParam String phone,
            @RequestParam int otp) {

        boolean valid = otpService.verifyOtp(phone, otp);

        if (valid) {
            return ResponseEntity.ok("Login successful");
        }
        return ResponseEntity.status(401).body("Invalid OTP");
    }
}

