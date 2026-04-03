package com.vitaflow.services;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
public class OtpService {

    @Value("${twilio.account-sid}")
    private String twilioAccountSid;

    @Value("${twilio.auth-token}")
    private String twilioAuthToken;

    @Value("${twilio.phone-number}")
    private String twilioPhoneNumber;

    // OTP storage (Phone -> OTP)
    // In production, use Redis or Database with expiration
    private final Map<String, String> otpStorage = new HashMap<>();

    @PostConstruct
    public void initTwilio() {
        Twilio.init(twilioAccountSid, twilioAuthToken);
        System.out.println("Twilio initialized successfully!");
    }

    public String generateOtp(String phoneNumber) {
        Random random = new Random();
        String otp = String.format("%04d", random.nextInt(10000));
        otpStorage.put(phoneNumber, otp);

        System.out.println("OTP for " + phoneNumber + ": " + otp);

        // Send OTP via Twilio SMS
        try {
            // Format number with country code if not present
            String formattedNumber = phoneNumber;
            if (!formattedNumber.startsWith("+")) {
                formattedNumber = "+91" + formattedNumber; // Default to India (+91)
            }

            Message message = Message.creator(
                    new PhoneNumber(formattedNumber),       // To
                    new PhoneNumber(twilioPhoneNumber),      // From (Twilio number)
                    "Your VitaFlow OTP is: " + otp + ". Do not share this with anyone."
            ).create();

            System.out.println("Twilio SMS sent! SID: " + message.getSid());
        } catch (Exception e) {
            System.err.println("Failed to send Twilio SMS: " + e.getMessage());
            // OTP is still stored, so user can use console OTP for dev/testing
        }

        return otp;
    }

    public boolean validateOtp(String phoneNumber, String otp) {
        if (otpStorage.containsKey(phoneNumber)) {
            String storedOtp = otpStorage.get(phoneNumber);
            if (storedOtp.equals(otp)) {
                // otpStorage.remove(phoneNumber); // Commented out to handle double requests from frontend
                return true;
            }
        }
        return false;
    }
}
