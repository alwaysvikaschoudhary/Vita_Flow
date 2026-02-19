package com.vitaflow.repositories;

import com.vitaflow.entities.BloodRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BloodRequestRepository extends JpaRepository<BloodRequest, String> {
    List<BloodRequest> findByHospitalId(String hospitalId);
    List<BloodRequest> findByStatus(String status);
    List<BloodRequest> findByDonorIdAndStatusIn(String donorId, List<String> statuses);
    List<BloodRequest> findByRiderIdAndStatusIn(String riderId, List<String> statuses);
}
