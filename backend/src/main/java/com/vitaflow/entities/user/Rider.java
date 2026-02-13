package com.vitaflow.entities.user;

import com.vitaflow.entities.Role;
import jakarta.persistence.*;
import lombok.*;

@Entity(name = "rider_user")
@Table(name = "rider_users")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Rider {

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

    private String bikeNumber; // For Rider
    
    @Enumerated(value = EnumType.STRING)
    private Role role;

    @PrePersist
    public void prePersist() {
        if (emailVerified == null) emailVerified = false;
        if (role == null) role = Role.RIDER;
    }

    private String gender;

    private String address;

    private String license;

    private String totalDeliveries;

    private String rating;

    private String vehicleType;

}

