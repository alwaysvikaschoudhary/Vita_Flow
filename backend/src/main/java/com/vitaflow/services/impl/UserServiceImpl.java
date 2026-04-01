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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;

import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
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

    @Autowired
    private PasswordEncoder passwordEncoder;

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
            if (doctor.get().getPassword() == null || !passwordEncoder.matches(password, doctor.get().getPassword())) {
                throw new RuntimeException("Incorrect password");
            }
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", doctor.get());
            return response;
        }

        Optional<Donor> donor = donorRepository.findByPhoneNumber(phoneNumber);
        if (donor.isPresent()) {
            if (donor.get().getPassword() == null || !passwordEncoder.matches(password, donor.get().getPassword())) {
                throw new RuntimeException("Incorrect password");
            }
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("token", "dummy-token");
            response.put("user", donor.get());
            return response;
        }

        Optional<Rider> rider = riderRepository.findByPhoneNumber(phoneNumber);
        if (rider.isPresent()) {
            if (rider.get().getPassword() == null || !passwordEncoder.matches(password, rider.get().getPassword())) {
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
        String hashedPass = passwordEncoder.encode(newPassword);

        Optional<Doctor> doctor = doctorRepository.findByPhoneNumber(phoneNumber);
        if (doctor.isPresent()) {
            doctor.get().setPassword(hashedPass);
            doctorRepository.save(doctor.get());
            return true;
        }

        Optional<Donor> donor = donorRepository.findByPhoneNumber(phoneNumber);
        if (donor.isPresent()) {
            donor.get().setPassword(hashedPass);
            donorRepository.save(donor.get());
            return true;
        }

        Optional<Rider> rider = riderRepository.findByPhoneNumber(phoneNumber);
        if (rider.isPresent()) {
            rider.get().setPassword(hashedPass);
            riderRepository.save(rider.get());
            return true;
        }

        return false;
    }

    @Override
    public boolean resetPasswordByEmail(String emailInput, String newPassword) {
        String email = emailInput.trim();
        String hashedPass = passwordEncoder.encode(newPassword);

        Optional<Doctor> doctor = doctorRepository.findByEmail(email);
        if (doctor.isPresent()) {
            doctor.get().setPassword(hashedPass);
            doctorRepository.save(doctor.get());
            return true;
        }

        Optional<Donor> donor = donorRepository.findByEmail(email);
        if (donor.isPresent()) {
            donor.get().setPassword(hashedPass);
            donorRepository.save(donor.get());
            return true;
        }

        Optional<Rider> rider = riderRepository.findByEmail(email);
        if (rider.isPresent()) {
            rider.get().setPassword(hashedPass);
            riderRepository.save(rider.get());
            return true;
        }

        return false;
    }

    private void validateEmailIsUnique(String email, String userId, String phoneNumber) {
        if (email == null || email.trim().isEmpty()) return;
        
        Optional<Doctor> existingDoc = doctorRepository.findByEmail(email);
        if (existingDoc.isPresent() && 
            (userId == null || !existingDoc.get().getUserId().equals(userId)) &&
            (phoneNumber == null || !existingDoc.get().getPhoneNumber().equals(phoneNumber))) {
            throw new RuntimeException("Email already in use");
        }
        
        Optional<Donor> existingDon = donorRepository.findByEmail(email);
        if (existingDon.isPresent() && 
            (userId == null || !existingDon.get().getUserId().equals(userId)) &&
            (phoneNumber == null || !existingDon.get().getPhoneNumber().equals(phoneNumber))) {
            throw new RuntimeException("Email already in use");
        }
        
        Optional<Rider> existingRid = riderRepository.findByEmail(email);
        if (existingRid.isPresent() && 
            (userId == null || !existingRid.get().getUserId().equals(userId)) &&
            (phoneNumber == null || !existingRid.get().getPhoneNumber().equals(phoneNumber))) {
            throw new RuntimeException("Email already in use");
        }
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
            if (doctor.getEmail() != null) {
                String newEmail = doctor.getEmail().trim().isEmpty() ? null : doctor.getEmail().trim();
                if (newEmail != null && !newEmail.equalsIgnoreCase(dbDoctor.getEmail())) {
                    validateEmailIsUnique(newEmail, dbDoctor.getUserId(), dbDoctor.getPhoneNumber());
                }
                dbDoctor.setEmail(newEmail);
            }
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
            if (doctor.getPassword() != null) dbDoctor.setPassword(passwordEncoder.encode(doctor.getPassword()));
            
            return doctorRepository.save(dbDoctor);
        }
        
        // Check if email already exists globally for new user
        if (doctor.getEmail() != null && !doctor.getEmail().trim().isEmpty()) {
            String email = doctor.getEmail().trim();
            validateEmailIsUnique(email, null, phoneNumber);
        }
        
        if (doctor.getUserId() == null) {
            doctor.setUserId(UUID.randomUUID().toString());
        }
        if (doctor.getPassword() != null) {
            doctor.setPassword(passwordEncoder.encode(doctor.getPassword()));
        }
        if (doctor.getEmail() != null && doctor.getEmail().trim().isEmpty()) {
            doctor.setEmail(null);
        }
        Doctor saved = doctorRepository.save(doctor);
        if (saved.getEmail() != null) {
            String subject = "Welcome to VitaFlow - Profile Completed!";
            String content = "Hello " + (saved.getName() != null ? saved.getName() : "User") + ",\n\n" +
                             "Thank you for completing your profile on VitaFlow as a " + saved.getRole() + ".\n\n" +
                             "Here are your registration details:\n" +
                             "Name: " + saved.getName() + "\n" +
                             "Phone: " + saved.getPhoneNumber() + "\n" +
                             "Email: " + saved.getEmail() + "\n" +
                             "Hospital: " + (saved.getHospitalName() != null ? saved.getHospitalName() : "N/A") + "\n" +
                             "Specialization: " + (saved.getSpecialization() != null ? saved.getSpecialization() : "N/A") + "\n" +
                             "Address: " + (saved.getAddress() != null ? saved.getAddress() : "N/A") + "\n\n" +
                             "You can now access all our features and help save lives.\n\n" +
                             "Best regards,\nVitaFlow Team";
            emailService.sendEmail(saved.getEmail(), subject, content);
        }
        return saved;
    }

    @Override
    public Donor saveDonor(Donor donor) {
        String phoneNumber = donor.getPhoneNumber().trim();
        donor.setPhoneNumber(phoneNumber);
        Optional<Donor> existing = donorRepository.findByPhoneNumber(phoneNumber);
        if (existing.isPresent()) {
            Donor dbDonor = existing.get();
            if (donor.getName() != null) dbDonor.setName(donor.getName());
            if (donor.getEmail() != null) {
                String newEmail = donor.getEmail().trim().isEmpty() ? null : donor.getEmail().trim();
                if (newEmail != null && !newEmail.equalsIgnoreCase(dbDonor.getEmail())) {
                    validateEmailIsUnique(newEmail, dbDonor.getUserId(), dbDonor.getPhoneNumber());
                }
                dbDonor.setEmail(newEmail);
            }
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
            if (donor.getPassword() != null) dbDonor.setPassword(passwordEncoder.encode(donor.getPassword()));
            
            return donorRepository.save(dbDonor);
        }
        
        // Check if email already exists globally for new user
        if (donor.getEmail() != null && !donor.getEmail().trim().isEmpty()) {
            String email = donor.getEmail().trim();
            validateEmailIsUnique(email, null, phoneNumber);
        }

        if (donor.getUserId() == null) {
            donor.setUserId(UUID.randomUUID().toString());
        }
        if (donor.getPassword() != null) {
            donor.setPassword(passwordEncoder.encode(donor.getPassword()));
        }
        if (donor.getEmail() != null && donor.getEmail().trim().isEmpty()) {
            donor.setEmail(null);
        }
        Donor saved = donorRepository.save(donor);
        if (saved.getEmail() != null) {
            String subject = "Welcome to VitaFlow - Profile Completed!";
            String content = "Hello " + (saved.getName() != null ? saved.getName() : "User") + ",\n\n" +
                             "Thank you for completing your profile on VitaFlow as a " + saved.getRole() + ".\n\n" +
                             "Here are your registration details:\n" +
                             "Name: " + saved.getName() + "\n" +
                             "Phone: " + saved.getPhoneNumber() + "\n" +
                             "Email: " + saved.getEmail() + "\n" +
                             "Blood Group: " + (saved.getBloodGroup() != null ? saved.getBloodGroup() : "N/A") + "\n" +
                             "Address: " + (saved.getAddress() != null ? saved.getAddress() : "N/A") + "\n\n" +
                             "Your contribution can save many lives. Thank you for joining us!\n\n" +
                             "Best regards,\nVitaFlow Team";
            emailService.sendEmail(saved.getEmail(), subject, content);
        }
        return saved;
    }

    @Override
    public Rider saveRider(Rider rider) {
        String phoneNumber = rider.getPhoneNumber().trim();
        rider.setPhoneNumber(phoneNumber);
        Optional<Rider> existing = riderRepository.findByPhoneNumber(phoneNumber);
        if (existing.isPresent()) {
            Rider dbRider = existing.get();
            if (rider.getName() != null) dbRider.setName(rider.getName());
            if (rider.getEmail() != null) {
                String newEmail = rider.getEmail().trim().isEmpty() ? null : rider.getEmail().trim();
                if (newEmail != null && !newEmail.equalsIgnoreCase(dbRider.getEmail())) {
                    validateEmailIsUnique(newEmail, dbRider.getUserId(), dbRider.getPhoneNumber());
                }
                dbRider.setEmail(newEmail);
            }
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
            if (rider.getPassword() != null) dbRider.setPassword(passwordEncoder.encode(rider.getPassword()));
            
            return riderRepository.save(dbRider);
        }
        
        // Check if email already exists globally for new user
        if (rider.getEmail() != null && !rider.getEmail().trim().isEmpty()) {
            String email = rider.getEmail().trim();
            validateEmailIsUnique(email, null, phoneNumber);
        }

        if (rider.getUserId() == null) {
            rider.setUserId(UUID.randomUUID().toString());
        }
        if (rider.getPassword() != null) {
            rider.setPassword(passwordEncoder.encode(rider.getPassword()));
        }
        if (rider.getEmail() != null && rider.getEmail().trim().isEmpty()) {
            rider.setEmail(null);
        }
        Rider saved = riderRepository.save(rider);
        if (saved.getEmail() != null) {
            String subject = "Welcome to VitaFlow - Profile Completed!";
            String content = "Hello " + (saved.getName() != null ? saved.getName() : "User") + ",\n\n" +
                             "Thank you for completing your profile on VitaFlow as a " + saved.getRole() + ".\n\n" +
                             "Here are your registration details:\n" +
                             "Name: " + saved.getName() + "\n" +
                             "Phone: " + saved.getPhoneNumber() + "\n" +
                             "Email: " + saved.getEmail() + "\n" +
                             "Vehicle Number: " + (saved.getBikeNumber() != null ? saved.getBikeNumber() : "N/A") + "\n" +
                             "Address: " + (saved.getAddress() != null ? saved.getAddress() : "N/A") + "\n\n" +
                             "As a rider, you play a crucial role in our mission. Get ready for your first delivery!\n\n" +
                             "Best regards,\nVitaFlow Team";
            emailService.sendEmail(saved.getEmail(), subject, content);
        }
        return saved;
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

    @Override
    public boolean changePassword(String phoneNumber, String oldPassword, String newPassword) {
        phoneNumber = phoneNumber.trim();
        
        Optional<Doctor> doctor = doctorRepository.findByPhoneNumber(phoneNumber);
        if (doctor.isPresent()) {
            Doctor d = doctor.get();
            if (d.getPassword() != null && passwordEncoder.matches(oldPassword, d.getPassword())) {
                d.setPassword(passwordEncoder.encode(newPassword));
                doctorRepository.save(d);
                return true;
            }
            return false;
        }

        Optional<Donor> donor = donorRepository.findByPhoneNumber(phoneNumber);
        if (donor.isPresent()) {
            Donor d = donor.get();
            if (d.getPassword() != null && passwordEncoder.matches(oldPassword, d.getPassword())) {
                d.setPassword(passwordEncoder.encode(newPassword));
                donorRepository.save(d);
                return true;
            }
            return false;
        }

        Optional<Rider> rider = riderRepository.findByPhoneNumber(phoneNumber);
        if (rider.isPresent()) {
            Rider r = rider.get();
            if (r.getPassword() != null && passwordEncoder.matches(oldPassword, r.getPassword())) {
                r.setPassword(passwordEncoder.encode(newPassword));
                riderRepository.save(r);
                return true;
            }
            return false;
        }

        return false;
    }
}
