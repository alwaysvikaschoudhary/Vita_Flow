package com.vitaflow.services;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
public class OtpService {

    // Simulating OTP storage (Phone -> OTP)
    // In production, use Redis or Database with expiration
    private final Map<String, String> otpStorage = new HashMap<>();

    public String generateOtp(String phoneNumber) {
        Random random = new Random();
        String otp = String.format("%04d", random.nextInt(10000));
        otpStorage.put(phoneNumber, otp);
        
        System.out.println("OTP for " + phoneNumber + ": " + otp); 
        
        return otp;
    }

    public boolean validateOtp(String phoneNumber, String otp) {

        if (otpStorage.containsKey(phoneNumber)) {
            String storedOtp = otpStorage.get(phoneNumber);
            if (storedOtp.equals(otp)) {
                // otpStorage.remove(phoneNumber); // OTP used once -- Commented out to handle double requests from frontend
                return true;
            }
        }
        return false;
    }
}
