package com.vitaflow.entities.user;

import com.vitaflow.entities.Role;
import jakarta.persistence.*;
import lombok.*;

@Entity(name = "doctor_user")
@Table(name = "doctor_users")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Doctor {

    @Id
    private String userId;

    private String name;

    // Email is now optional
    private String email;

    private String password; // Optional if using OTP only

    private String dob;

    @Column(length = 2000)
    private String about;

    @Column(length = 1000)
    private String profilePic;

    @Column(unique = true, nullable = false)
    private String phoneNumber;

    @Builder.Default
    private Boolean emailVerified = false;

    private String hospitalName; // For Doctor/Hospital

    private String specialization; // For Doctor
    
    @Enumerated(value = EnumType.STRING)
    private Role role;

    @PrePersist
    public void prePersist() {
        if (emailVerified == null) emailVerified = false;
        if (role == null) role = Role.DOCTOR;
    }

    private String gender;

    private String address;

    private String HospitalId;

    private String degree;

    private String experience;

}

