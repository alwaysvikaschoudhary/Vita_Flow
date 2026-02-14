package com.vitaflow.entities.user;

import com.vitaflow.entities.Role;
import com.vitaflow.entities.Ordinate;
import jakarta.persistence.*;
import lombok.*;

@Entity(name = "donor_user")
@Table(name = "donor_users")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Donor {

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

    // Role Specific Fields
    private String bloodGroup;
    
    @Enumerated(value = EnumType.STRING)
    private Role role;

    @PrePersist
    public void prePersist() {
        if (emailVerified == null) emailVerified = false;
        if (role == null) role = Role.DONOR;
    }

    private String address;

    private String age;

    private String gender;

    private String weight;

    private String height;

    private String medicalHistory;

    private String numberOfDonation;

    private String lastDonationDate;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "latitude", column = @Column(name = "location_lat")),
        @AttributeOverride(name = "longitude", column = @Column(name = "location_lng"))
    })
    private Ordinate ordinate;

}

