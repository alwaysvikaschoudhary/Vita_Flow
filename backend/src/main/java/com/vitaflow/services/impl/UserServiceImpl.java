package com.vitaflow.services.impl;

import com.vitaflow.entities.Role;
import com.vitaflow.entities.user.Doctor;
import com.vitaflow.entities.user.Donor;
import com.vitaflow.entities.user.Rider;
import com.vitaflow.repositories.DoctorRepository;
import com.vitaflow.repositories.DonorRepository;
import com.vitaflow.repositories.RiderRepository;
import com.vitaflow.services.OtpService;
import com.vitaflow.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private DoctorRepository doctorRepository;
    
    @Autowired
    private DonorRepository donorRepository;
    
    @Autowired
    private RiderRepository riderRepository;

    @Autowired
    private OtpService otpService;

    @Autowired
    private com.vitaflow.services.EmailService emailService;

    // @Autowired
    // private JwtUtil jwtUtil; // Not using JWT anymore

    @Override
    public boolean sendOtp(String phoneNumber) {
        otpService.generateOtp(phoneNumber);
        return true;
    }

    @Override
    public java.util.Map<String, Object> verifyOtp(String phoneNumberInput, String otp) {
        String phoneNumber = phoneNumberInput.trim();
        System.out.println("Verifying OTP for: '" + phoneNumber + "' with OTP: '" + otp + "'");
        
        if (!otpService.validateOtp(phoneNumber, otp)) {
            System.out.println("OTP Validation Failed for: " + phoneNumber);
            throw new RuntimeException("Invalid OTP");
        }

        System.out.println("OTP Validated. Checking repositories...");

        // Check if user exists in any of the repositories
        Optional<Doctor> doctor = doctorRepository.findByPhoneNumber(phoneNumber);
        if (doctor.isPresent()) {
            System.out.println("Found Doctor: " + doctor.get().getUserId());
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", doctor.get());
            return response;
        }

        Optional<Donor> donor = donorRepository.findByPhoneNumber(phoneNumber);
        if (donor.isPresent()) {
             System.out.println("Found Donor: " + donor.get().getUserId());
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", donor.get());
            return response;
        }

        Optional<Rider> rider = riderRepository.findByPhoneNumber(phoneNumber);
        if (rider.isPresent()) {
             System.out.println("Found Rider: " + rider.get().getUserId());
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", rider.get());
            return response;
        }

        System.out.println("User not found in any repository. Returning new user response.");
        // If user is new
        java.util.Map<String, Object> response = new java.util.HashMap<>();
        response.put("token", null);
        response.put("user", null);
        return response;
    }

    @Override
    public boolean sendEmailOtp(String email) {
        // Check if email exists in any repository
        boolean exists = doctorRepository.findByEmail(email).isPresent() ||
                         donorRepository.findByEmail(email).isPresent() ||
                         riderRepository.findByEmail(email).isPresent();
        
        if (!exists) {
            throw new RuntimeException("No account found with this email address");
        }

        String otp = otpService.generateOtp(email);
        emailService.sendEmail(email, "VitaFlow Password Reset OTP", "Your OTP for password reset is: " + otp);
        return true;
    }

    @Override
    public java.util.Map<String, Object> verifyEmailOtp(String emailInput, String otp) {
        String email = emailInput.trim();
        if (!otpService.validateOtp(email, otp)) {
            throw new RuntimeException("Invalid OTP");
        }

        Optional<Doctor> doctor = doctorRepository.findByEmail(email);
        if (doctor.isPresent()) {
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", doctor.get());
            return response;
        }

        Optional<Donor> donor = donorRepository.findByEmail(email);
        if (donor.isPresent()) {
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", donor.get());
            return response;
        }

        Optional<Rider> rider = riderRepository.findByEmail(email);
        if (rider.isPresent()) {
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", rider.get());
            return response;
        }

        throw new RuntimeException("User not found after OTP verification");
    }

    @Override
    public java.util.Map<String, Object> loginWithPassword(String phoneNumberInput, String password) {
        String phoneNumber = phoneNumberInput.trim();
        System.out.println("Password login for: '" + phoneNumber + "'");

        Optional<Doctor> doctor = doctorRepository.findByPhoneNumber(phoneNumber);
        if (doctor.isPresent()) {
            if (doctor.get().getPassword() == null || !doctor.get().getPassword().equals(password)) {
                throw new RuntimeException("Incorrect password");
            }
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", doctor.get());
            return response;
        }

        Optional<Donor> donor = donorRepository.findByPhoneNumber(phoneNumber);
        if (donor.isPresent()) {
            if (donor.get().getPassword() == null || !donor.get().getPassword().equals(password)) {
                throw new RuntimeException("Incorrect password");
            }
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", donor.get());
            return response;
        }

        Optional<Rider> rider = riderRepository.findByPhoneNumber(phoneNumber);
        if (rider.isPresent()) {
            if (rider.get().getPassword() == null || !rider.get().getPassword().equals(password)) {
                throw new RuntimeException("Incorrect password");
            }
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", rider.get());
            return response;
        }

        throw new RuntimeException("No account found with this phone number");
    }

    @Override
    public boolean resetPassword(String phoneNumberInput, String newPassword) {
        String phoneNumber = phoneNumberInput.trim();

        Optional<Doctor> doctor = doctorRepository.findByPhoneNumber(phoneNumber);
        if (doctor.isPresent()) {
            doctor.get().setPassword(newPassword);
            doctorRepository.save(doctor.get());
            return true;
        }

        Optional<Donor> donor = donorRepository.findByPhoneNumber(phoneNumber);
        if (donor.isPresent()) {
            donor.get().setPassword(newPassword);
            donorRepository.save(donor.get());
            return true;
        }

        Optional<Rider> rider = riderRepository.findByPhoneNumber(phoneNumber);
        if (rider.isPresent()) {
            rider.get().setPassword(newPassword);
            riderRepository.save(rider.get());
            return true;
        }

        return false;
    }

    @Override
    public boolean resetPasswordByEmail(String emailInput, String newPassword) {
        String email = emailInput.trim();

        Optional<Doctor> doctor = doctorRepository.findByEmail(email);
        if (doctor.isPresent()) {
            doctor.get().setPassword(newPassword);
            doctorRepository.save(doctor.get());
            return true;
        }

        Optional<Donor> donor = donorRepository.findByEmail(email);
        if (donor.isPresent()) {
            donor.get().setPassword(newPassword);
            donorRepository.save(donor.get());
            return true;
        }

        Optional<Rider> rider = riderRepository.findByEmail(email);
        if (rider.isPresent()) {
            rider.get().setPassword(newPassword);
            riderRepository.save(rider.get());
            return true;
        }

        return false;
    }
    
    @Override
    public Doctor saveDoctor(Doctor doctor) {
        String phoneNumber = doctor.getPhoneNumber().trim();
        doctor.setPhoneNumber(phoneNumber);
        Optional<Doctor> existing = doctorRepository.findByPhoneNumber(phoneNumber);
        if (existing.isPresent()) {
            Doctor dbDoctor = existing.get();
            // Update fields only if they are not null
            if (doctor.getName() != null) dbDoctor.setName(doctor.getName());
            if (doctor.getEmail() != null) dbDoctor.setEmail(doctor.getEmail());
            if (doctor.getHospitalName() != null) dbDoctor.setHospitalName(doctor.getHospitalName());
            if (doctor.getSpecialization() != null) dbDoctor.setSpecialization(doctor.getSpecialization());
            if (doctor.getAbout() != null) dbDoctor.setAbout(doctor.getAbout());
            if (doctor.getProfilePic() != null) dbDoctor.setProfilePic(doctor.getProfilePic());
            if (doctor.getGender() != null) dbDoctor.setGender(doctor.getGender());
            if (doctor.getAddress() != null) dbDoctor.setAddress(doctor.getAddress());
            if (doctor.getHospitalId() != null) dbDoctor.setHospitalId(doctor.getHospitalId());
            if (doctor.getDegree() != null) dbDoctor.setDegree(doctor.getDegree());
            if (doctor.getExperience() != null) dbDoctor.setExperience(doctor.getExperience());
            if (doctor.getOrdinate() != null) dbDoctor.setOrdinate(doctor.getOrdinate());
            if (doctor.getPassword() != null) dbDoctor.setPassword(doctor.getPassword());
            
            return doctorRepository.save(dbDoctor);
        }
        
        // Check if email already exists globally for new user
        if (doctor.getEmail() != null && !doctor.getEmail().trim().isEmpty()) {
            String email = doctor.getEmail().trim();
            if (doctorRepository.findByEmail(email).isPresent() ||
                donorRepository.findByEmail(email).isPresent() ||
                riderRepository.findByEmail(email).isPresent()) {
                throw new RuntimeException("Email already in use");
            }
        }
        
        if (doctor.getUserId() == null) {
            doctor.setUserId(UUID.randomUUID().toString());
        }
        return doctorRepository.save(doctor);
    }

    @Override
    public Donor saveDonor(Donor donor) {
        String phoneNumber = donor.getPhoneNumber().trim();
        donor.setPhoneNumber(phoneNumber);
        Optional<Donor> existing = donorRepository.findByPhoneNumber(phoneNumber);
        if (existing.isPresent()) {
            Donor dbDonor = existing.get();
            if (donor.getName() != null) dbDonor.setName(donor.getName());
            if (donor.getEmail() != null) dbDonor.setEmail(donor.getEmail());
            if (donor.getBloodGroup() != null) dbDonor.setBloodGroup(donor.getBloodGroup());
            if (donor.getAbout() != null) dbDonor.setAbout(donor.getAbout());
            if (donor.getProfilePic() != null) dbDonor.setProfilePic(donor.getProfilePic());
            if (donor.getAddress() != null) dbDonor.setAddress(donor.getAddress());
            if (donor.getAge() != null) dbDonor.setAge(donor.getAge());
            if (donor.getGender() != null) dbDonor.setGender(donor.getGender());
            if (donor.getWeight() != null) dbDonor.setWeight(donor.getWeight());
            if (donor.getHeight() != null) dbDonor.setHeight(donor.getHeight());
            if (donor.getMedicalHistory() != null) dbDonor.setMedicalHistory(donor.getMedicalHistory());
            if (donor.getNumberOfDonation() != null) dbDonor.setNumberOfDonation(donor.getNumberOfDonation());
            if (donor.getLastDonationDate() != null) dbDonor.setLastDonationDate(donor.getLastDonationDate());
            if (donor.getOrdinate() != null) dbDonor.setOrdinate(donor.getOrdinate());
            if (donor.getPassword() != null) dbDonor.setPassword(donor.getPassword());
            
            return donorRepository.save(dbDonor);
        }
        
        // Check if email already exists globally for new user
        if (donor.getEmail() != null && !donor.getEmail().trim().isEmpty()) {
            String email = donor.getEmail().trim();
            if (doctorRepository.findByEmail(email).isPresent() ||
                donorRepository.findByEmail(email).isPresent() ||
                riderRepository.findByEmail(email).isPresent()) {
                throw new RuntimeException("Email already in use");
            }
        }

        if (donor.getUserId() == null) {
            donor.setUserId(UUID.randomUUID().toString());
        }
        return donorRepository.save(donor);
    }

    @Override
    public Rider saveRider(Rider rider) {
        String phoneNumber = rider.getPhoneNumber().trim();
        rider.setPhoneNumber(phoneNumber);
        Optional<Rider> existing = riderRepository.findByPhoneNumber(phoneNumber);
        if (existing.isPresent()) {
            Rider dbRider = existing.get();
            if (rider.getName() != null) dbRider.setName(rider.getName());
            if (rider.getEmail() != null) dbRider.setEmail(rider.getEmail());
            if (rider.getBikeNumber() != null) dbRider.setBikeNumber(rider.getBikeNumber());
            if (rider.getAbout() != null) dbRider.setAbout(rider.getAbout());
            if (rider.getProfilePic() != null) dbRider.setProfilePic(rider.getProfilePic());
            if (rider.getGender() != null) dbRider.setGender(rider.getGender());
            if (rider.getAddress() != null) dbRider.setAddress(rider.getAddress());
            if (rider.getLicense() != null) dbRider.setLicense(rider.getLicense());
            if (rider.getTotalDeliveries() != null) dbRider.setTotalDeliveries(rider.getTotalDeliveries());
            if (rider.getRating() != null) dbRider.setRating(rider.getRating());
            if (rider.getVehicleType() != null) dbRider.setVehicleType(rider.getVehicleType());
            if (rider.getOrdinate() != null) dbRider.setOrdinate(rider.getOrdinate());
            if (rider.getPassword() != null) dbRider.setPassword(rider.getPassword());
            
            return riderRepository.save(dbRider);
        }
        
        // Check if email already exists globally for new user
        if (rider.getEmail() != null && !rider.getEmail().trim().isEmpty()) {
            String email = rider.getEmail().trim();
            if (doctorRepository.findByEmail(email).isPresent() ||
                donorRepository.findByEmail(email).isPresent() ||
                riderRepository.findByEmail(email).isPresent()) {
                throw new RuntimeException("Email already in use");
            }
        }

        if (rider.getUserId() == null) {
            rider.setUserId(UUID.randomUUID().toString());
        }
        return riderRepository.save(rider);
    }

    @Override
    public Doctor getDoctorById(String userId) {
        return doctorRepository.findById(userId).orElseThrow(() -> new RuntimeException("Doctor not found"));
    }

    @Override
    public Donor getDonorById(String userId) {
        return donorRepository.findById(userId).orElseThrow(() -> new RuntimeException("Donor not found"));
    }

    @Override
    public Rider getRiderById(String userId) {
        return riderRepository.findById(userId).orElseThrow(() -> new RuntimeException("Rider not found"));
    }

    @Override
    public boolean updateUserLocation(String phoneNumber, com.vitaflow.payload.LocationDTO location) {
        Optional<Doctor> doctor = doctorRepository.findByPhoneNumber(phoneNumber);
        if (doctor.isPresent()) {
            Doctor d = doctor.get();
            if (d.getOrdinate() == null) d.setOrdinate(new com.vitaflow.entities.Ordinate());
            d.getOrdinate().setLatitude(location.getLatitude());
            d.getOrdinate().setLongitude(location.getLongitude());
            doctorRepository.save(d);
            return true;
        }

        Optional<Donor> donor = donorRepository.findByPhoneNumber(phoneNumber);
        if (donor.isPresent()) {
            Donor d = donor.get();
            if (d.getOrdinate() == null) d.setOrdinate(new com.vitaflow.entities.Ordinate());
            d.getOrdinate().setLatitude(location.getLatitude());
            d.getOrdinate().setLongitude(location.getLongitude());
            donorRepository.save(d);
            return true;
        }

        Optional<Rider> rider = riderRepository.findByPhoneNumber(phoneNumber);
        if (rider.isPresent()) {
            Rider r = rider.get();
            if (r.getOrdinate() == null) r.setOrdinate(new com.vitaflow.entities.Ordinate());
            r.getOrdinate().setLatitude(location.getLatitude());
            r.getOrdinate().setLongitude(location.getLongitude());
            riderRepository.save(r);
            return true;
        }

        return false;
    }

    @Override
    public boolean existsByPhoneNumber(String phoneNumber) {
        return doctorRepository.findByPhoneNumber(phoneNumber).isPresent() ||
               donorRepository.findByPhoneNumber(phoneNumber).isPresent() ||
               riderRepository.findByPhoneNumber(phoneNumber).isPresent();
    }
}
