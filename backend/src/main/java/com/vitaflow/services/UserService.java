package com.vitaflow.services;


import com.vitaflow.payload.LocationDTO;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface UserService {

    // Auth — OTP
    java.util.Map<String, Object> verifyOtp(String phoneNumber, String otp);
    boolean sendOtp(String phoneNumber);

    // Auth — Email OTP
    boolean sendEmailOtp(String email);
    java.util.Map<String, Object> verifyEmailOtp(String email, String otp);

    // Auth — Password
    java.util.Map<String, Object> loginWithPassword(String phoneNumber, String password);
    boolean resetPassword(String phoneNumber, String newPassword);
    boolean resetPasswordByEmail(String email, String newPassword);
    
    // Role Specific Save Methods
    com.vitaflow.entities.user.Doctor saveDoctor(com.vitaflow.entities.user.Doctor doctor);
    com.vitaflow.entities.user.Donor saveDonor(com.vitaflow.entities.user.Donor donor);
    com.vitaflow.entities.user.Rider saveRider(com.vitaflow.entities.user.Rider rider);
    
    // Role Specific Get Methods
    com.vitaflow.entities.user.Doctor getDoctorById(String userId);
    com.vitaflow.entities.user.Donor getDonorById(String userId);
    com.vitaflow.entities.user.Rider getRiderById(String userId);

    public boolean updateUserLocation(String phoneNumber, LocationDTO location);
    boolean existsByPhoneNumber(String phoneNumber);
}
