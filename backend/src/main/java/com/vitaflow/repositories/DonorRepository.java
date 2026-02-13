package com.vitaflow.repositories;

import com.vitaflow.entities.user.Donor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DonorRepository extends JpaRepository<Donor, String> {
    Optional<Donor> findByPhoneNumber(String phoneNumber);
}
