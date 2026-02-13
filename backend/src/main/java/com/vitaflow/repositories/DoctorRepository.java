package com.vitaflow.repositories;

import com.vitaflow.entities.user.Doctor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DoctorRepository extends JpaRepository<Doctor, String> {
    Optional<Doctor> findByPhoneNumber(String phoneNumber);
}
