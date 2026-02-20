package com.vitaflow.services;

import com.vitaflow.entities.BloodRequest;

import java.util.List;

public interface BloodRequestService {
    BloodRequest createRequest(BloodRequest request);
    List<BloodRequest> getAllRequests();
    List<BloodRequest> getRequestsByStatus(String status);
    List<BloodRequest> getRequestsByHospital(String hospitalId);
    BloodRequest acceptRequest(String requestId, String donorId, String donorName, Double latitude, Double longitude);
    BloodRequest getRequestById(String requestId);
    List<BloodRequest> findActiveRequestsForDonor(String donorId);
    List<BloodRequest> findHistoryForDonor(String donorId);
    List<BloodRequest> findHistoryForRider(String riderId);
    BloodRequest assignRider(String requestId, String riderId);
}
