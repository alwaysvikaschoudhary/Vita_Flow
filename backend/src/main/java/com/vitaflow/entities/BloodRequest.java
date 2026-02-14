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

}