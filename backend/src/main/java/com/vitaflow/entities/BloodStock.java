package com.vitaflow.entities;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "blood_stocks")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class BloodStock {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String hospitalId;

    @Column(name = "a_positive", nullable = false)
    private Integer ap = 0; // A+

    @Column(name = "a_negative", nullable = false)
    private Integer an = 0; // A-

    @Column(name = "b_positive", nullable = false)
    private Integer bp = 0; // B+

    @Column(name = "b_negative", nullable = false)
    private Integer bn = 0; // B-

    @Column(name = "ab_positive", nullable = false)
    private Integer abp = 0; // AB+

    @Column(name = "ab_negative", nullable = false)
    private Integer abn = 0; // AB-

    @Column(name = "o_positive", nullable = false)
    private Integer op = 0; // O+

    @Column(name = "o_negative", nullable = false)
    private Integer on = 0; // O-
}
