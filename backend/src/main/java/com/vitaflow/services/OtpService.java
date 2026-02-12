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
        
        // Fast2SMS Integration
        sendFast2SmsOtp(phoneNumber, otp);
        
        return otp;
    }

    private void sendFast2SmsOtp(String phoneNumber, String otp) {
        try {
            String apiKey = "YOUR_FAST2SMS_API_KEY"; // Replace with actual API Key
            String url = "https://www.fast2sms.com/dev/bulkV2?authorization=" + apiKey + 
                         "&route=otp&variables_values=" + otp + 
                         "&flash=0&numbers=" + phoneNumber;
            
            org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();
            String response = restTemplate.getForObject(url, String.class);
            System.out.println("Fast2SMS Response: " + response);
        } catch (Exception e) {
            System.err.println("Error sending OTP via Fast2SMS: " + e.getMessage());
            // Don't block flow if SMS fails, rely on console log for dev
        }
    }

    public boolean validateOtp(String phoneNumber, String otp) {

        if (otpStorage.containsKey(phoneNumber)) {
            String storedOtp = otpStorage.get(phoneNumber);
            if (storedOtp.equals(otp)) {
                otpStorage.remove(phoneNumber); // OTP used once
                return true;
            }
        }
        return false;
    }
}
