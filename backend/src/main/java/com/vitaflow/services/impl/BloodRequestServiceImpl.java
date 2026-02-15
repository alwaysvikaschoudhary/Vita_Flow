package com.vitaflow.services.impl;

import com.vitaflow.entities.BloodRequest;
import com.vitaflow.repositories.BloodRequestRepository;
import com.vitaflow.services.BloodRequestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class BloodRequestServiceImpl implements BloodRequestService {

    @Autowired
    private BloodRequestRepository requestRepository;

    @Autowired
    private com.vitaflow.repositories.DoctorRepository doctorRepository;

    @Override
    public BloodRequest createRequest(BloodRequest request) {
        if (request.getRequestId() == null || request.getRequestId().isEmpty()) {
            request.setRequestId(UUID.randomUUID().toString());
        }
        // Ensure hospital name is set on creation if possible, or transient is fine
        return requestRepository.save(request);
    }

    @Override
    public List<BloodRequest> getAllRequests() {
        return requestRepository.findAll();
    }

    @Override
    public List<BloodRequest> getRequestsByStatus(String status) {
        return requestRepository.findByStatus(status);
    }

    @Override
    public List<BloodRequest> getRequestsByHospital(String hospitalId) {
        return requestRepository.findByHospitalId(hospitalId);
    }

    @Override
    public BloodRequest acceptRequest(String requestId, String donorId) {
        BloodRequest request = requestRepository.findById(requestId).orElse(null);
        if (request == null) {
            throw new RuntimeException("Request not found");
        }
        if (!"PENDING".equalsIgnoreCase(request.getStatus())) {
            throw new RuntimeException("Request is already " + request.getStatus());
        }
        
        request.setStatus("ACCEPTED");
        request.setDonorId(donorId);
        
        String otp = String.format("%04d", new java.util.Random().nextInt(10000));
        request.setOtp(otp);
        
        BloodRequest saved = requestRepository.save(request);
        populateHospitalName(saved);
        return saved;
    }

    @Override
    public BloodRequest getRequestById(String requestId) {
         BloodRequest request = requestRepository.findById(requestId).orElse(null);
         if (request != null) {
             populateHospitalName(request);
         }
         return request;
    }

    private void populateHospitalName(BloodRequest request) {
        if (request.getHospitalId() != null) {
            doctorRepository.findById(request.getHospitalId()).ifPresent(doctor -> {
                request.setHospitalName(doctor.getHospitalName());
            });
        }
    }
}
