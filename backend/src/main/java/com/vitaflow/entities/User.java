package com.vitaflow.entities;

import jakarta.persistence.*;
import lombok.*;
import java.util.LinkedHashSet;
import java.util.Set;

@Entity(name = "user")
@Table(name = "users")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class User {

    @Id
    private String userId;

    @Column(name = "user_name")
    private String name;
    
    // Email is now optional
    private String email;
    
    private String password; // Optional if using OTP only
    
    @Lob
    private String about;
    
    @Column(length = 1000)
    private String profilePic;
    
    @Column(unique = true, nullable = false)
    private String phoneNumber;

    @Builder.Default
    private Boolean emailVerified = false;



    @Enumerated(value = EnumType.STRING)
    private Role role;

    // Role Specific Fields
    private String bloodGroup; // For Donor
    private String dob;        // For All (Donor/Rider/Doctor)
    private String hospitalName; // For Doctor/Hospital
    private String specialization; // For Doctor
    private String bikeNumber; // For Rider

    @PrePersist
    public void prePersist() {
        if (emailVerified == null) emailVerified = false;
    }
}

