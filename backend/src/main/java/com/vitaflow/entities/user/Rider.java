package com.vitaflow.entities.user;

import com.vitaflow.entities.Role;
import com.vitaflow.entities.Ordinate;
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

    @Column(unique = true)
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
        if (referralId == null && phoneNumber != null) {
            referralId = "vita" + phoneNumber.trim();
        }
        if (rewardsCoin == null) {
            rewardsCoin = "0";
        }
        if (referralCount == null) {
            referralCount = 0;
        }
    }

    private String gender;

    private String address;

    private String license;

    private String totalDeliveries;

    private String rating;

    private String vehicleType;

    @Column(unique = true)
    private String referralId;

    private String rewardsCoin;

    private String referredBy;

    @Builder.Default
    private Integer referralCount = 0;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "latitude", column = @Column(name = "location_lat")),
        @AttributeOverride(name = "longitude", column = @Column(name = "location_lng"))
    })
    private Ordinate ordinate;

}

