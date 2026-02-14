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

    @Override
    public BloodRequest createRequest(BloodRequest request) {
        if (request.getRequestId() == null || request.getRequestId().isEmpty()) {
            request.setRequestId(UUID.randomUUID().toString());
        }
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
}
