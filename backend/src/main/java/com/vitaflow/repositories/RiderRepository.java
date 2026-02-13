package com.vitaflow.repositories;

import com.vitaflow.entities.user.Rider;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RiderRepository extends JpaRepository<Rider, String> {
    Optional<Rider> findByPhoneNumber(String phoneNumber);
}
