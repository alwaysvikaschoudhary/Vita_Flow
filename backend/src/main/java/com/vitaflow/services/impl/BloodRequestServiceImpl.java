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
    private com.vitaflow.repositories.DonorRepository donorRepository;

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
    public BloodRequest acceptRequest(String requestId, String donorId, String donorName, Double latitude, Double longitude) {
        BloodRequest request = requestRepository.findById(requestId).orElse(null);
        if (request == null) {
            throw new RuntimeException("Request not found");
        }
        if (!"PENDING".equalsIgnoreCase(request.getStatus())) {
            throw new RuntimeException("Request is already " + request.getStatus());
        }
        
        request.setStatus("ACCEPTED");
        request.setDonorId(donorId);
        
        // Fetch actual donor name from DB
        String actualDonorName = donorName;
        if (donorId != null) {
            com.vitaflow.entities.user.Donor donor = donorRepository.findById(donorId).orElse(null);
            if (donor != null) {
                actualDonorName = donor.getName();
            }
        }
        request.setDonorName(actualDonorName);
        
        if (latitude != null && longitude != null) {
            request.setPickupOrdinate(new com.vitaflow.entities.Ordinate(latitude, longitude));
        }
        
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
                // Also populate doctor name if not already set, or override depending on requirement.
                // The user wants "Hospital (DoctorName)".
                if (request.getDoctorName() == null || request.getDoctorName().isEmpty()) {
                    request.setDoctorName(doctor.getName());
                }
            });
        }
    }

    @Override
    public List<BloodRequest> findActiveRequestsForDonor(String donorId) {
        // statuses: ACCEPTED, ON_THE_WAY, ARRIVED - basically anything not PENDING, COMPLETED, CANCELLED
        // For now let's stick to accepted/on_the_way
        List<String> activeStatuses = List.of("ACCEPTED", "ON_THE_WAY", "PICKED_UP");
        List<BloodRequest> requests = requestRepository.findByDonorIdAndStatusIn(donorId, activeStatuses);
        requests.forEach(this::populateHospitalName);
        return requests;
    }
    @Override
    public List<BloodRequest> findHistoryForDonor(String donorId) {
        List<String> historyStatuses = List.of("COMPLETED", "PICKED_UP", "CANCELLED", "DELIVERED");
        List<BloodRequest> requests = requestRepository.findByDonorIdAndStatusIn(donorId, historyStatuses);
        requests.forEach(this::populateHospitalName);
        return requests;
    }
}
