package com.vitaflow.backend.services;

import com.vitaflow.backend.entities.User;
import com.vitaflow.backend.repositories.UserRepo;
import com.vitaflow.backend.util.SmsUtil;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

@Service
public class OtpService {

    private final UserRepo userRepo;

    // phone -> otp
    private final Map<String, Integer> otpStore = new HashMap<>();
    private final Map<String, Long> otpExpiry = new HashMap<>();

    public OtpService(UserRepo userRepo) {
        this.userRepo = userRepo;
    }

    public void sendOtp(String phone) {

        int otp = 100000 + new Random().nextInt(900000);

        otpStore.put(phone, otp);
        otpExpiry.put(phone, System.currentTimeMillis() + 5 * 60 * 1000);

        String message = "Your OTP is " + otp + ". Valid for 5 minutes.";
        SmsUtil.sendSms(message, phone);
    }

    public String verifyOtpAndLogin(String phone, int otp) {

        if (!verifyOtp(phone, otp)) {
            throw new RuntimeException("Invalid OTP");
        }

        User user = userRepo.findByPhone(phone)
                .orElseGet(() -> {
                    User u = new User();
                    u.setUserId(UUID.randomUUID().toString());
                    u.setPhone(phone);
                    return userRepo.save(u);
                });

        return user.getUserId();
    }

    private boolean verifyOtp(String phone, int otp) {

        Integer storedOtp = otpStore.get(phone);
        Long expiry = otpExpiry.get(phone);

        if (storedOtp == null || expiry == null) return false;

        if (System.currentTimeMillis() > expiry) {
            otpStore.remove(phone);
            otpExpiry.remove(phone);
            return false;
        }

        if (storedOtp != otp) return false;

        otpStore.remove(phone);
        otpExpiry.remove(phone);
        return true;
    }
}
