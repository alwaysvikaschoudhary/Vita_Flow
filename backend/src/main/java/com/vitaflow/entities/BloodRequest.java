package com.vitaflow.entities;

import jakarta.persistence.*;
import lombok.*;

@Entity(name = "blood_request")
@Table(name = "blood_requests")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BloodRequest {

    @Id
    private String requestId;

    private String bloodGroup;

    private String units;

    private String urgency;

    private String status;

    private String date;

    private String time;

    private String donorId;

    private String hospitalId;

    private String doctorName;

    private String riderId;

    private Ordinate ordinate;

    @Transient
    private String hospitalName;

    private String otp;

    private String donorName;

    private String riderName;

    private String donorPhoneNumber;
    
    private String riderBikeNumber;
    
    private String riderPhoneNumber;
    
    private String doctorPhoneNumber;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "latitude", column = @Column(name = "pickup_latitude")),
        @AttributeOverride(name = "longitude", column = @Column(name = "pickup_longitude"))
    })
    private Ordinate pickupOrdinate;

}