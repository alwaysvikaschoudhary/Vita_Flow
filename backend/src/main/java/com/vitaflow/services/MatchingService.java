package com.vitaflow.services;

import com.vitaflow.entities.Ordinate;
import com.vitaflow.entities.user.Donor;
import com.vitaflow.repositories.DonorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MatchingService {

    @Autowired
    private com.vitaflow.repositories.DoctorRepository doctorRepository;

    @Autowired
    private DonorRepository donorRepository;

    @Autowired
    private com.vitaflow.repositories.BloodRequestRepository bloodRequestRepository;

    @Autowired
    private GoogleDistanceService googleDistanceService;

    public List<Donor> findNearbyDonors(String bloodGroup, Ordinate doctorLocation) {
        // 1. Fetch available donors with matching blood group
        // Note: In a real app, you might want to filter is_available = true in the query
        List<Donor> allMatchingDonors = donorRepository.findAll().stream()
                .filter(d -> d.getBloodGroup() != null && d.getBloodGroup().equalsIgnoreCase(bloodGroup))
                .filter(d -> d.getOrdinate() != null && d.getOrdinate().getLatitude() != null && d.getOrdinate().getLongitude() != null)
                .collect(Collectors.toList());

        if (allMatchingDonors.isEmpty()) {
            return new ArrayList<>();
        }

        // 2. Extract locations
        List<Ordinate> donorLocations = allMatchingDonors.stream()
                .map(Donor::getOrdinate)
                .collect(Collectors.toList());

        // 3. Get Distances from Google API
        List<Double> distances = googleDistanceService.getDistances(doctorLocation, donorLocations);

        // 4. Map Donors to Distances and Filter
        List<DonorDistance> donorDistances = new ArrayList<>();
        for (int i = 0; i < allMatchingDonors.size(); i++) {
            double dist = distances.get(i);
            if (dist <= 50.0) { // Filter donors within 50 KM (User asked for 5KM but 50 seems safer for testing, or we can make it configurable. Let's stick to 5km as requested or slightly larger buffer? I'll use 50km for now to ensure results in testing, user asked for 5KM in request. I will stick to user request 5KM but maybe I'll comment it.)
                 // User asked for 5KM.
                if (dist <= 5.0) {
                     donorDistances.add(new DonorDistance(allMatchingDonors.get(i), dist));
                }
            }
        }

        // 5. Sort by distance
        donorDistances.sort(Comparator.comparingDouble(DonorDistance::getDistance));

        // 6. Return Donors
        return donorDistances.stream().map(DonorDistance::getDonor).collect(Collectors.toList());
    }

    public List<com.vitaflow.entities.BloodRequest> findNearbyRequests(String donorBloodGroup, Ordinate donorLocation) {
        // 1. Fetch all PENDING requests
        List<com.vitaflow.entities.BloodRequest> allPendingRequests = bloodRequestRepository.findByStatus("PENDING");

        if (allPendingRequests.isEmpty()) {
            return new ArrayList<>();
        }

        // 2. Filter by Blood Group Compatibility
        List<com.vitaflow.entities.BloodRequest> compatibleRequests = allPendingRequests.stream()
                .filter(req -> isCompatible(donorBloodGroup, req.getBloodGroup()))
                .filter(req -> req.getOrdinate() != null && req.getOrdinate().getLatitude() != null && req.getOrdinate().getLongitude() != null)
                .collect(Collectors.toList());

        if (compatibleRequests.isEmpty()) {
             return new ArrayList<>();
        }

        // 3. Extract Request Locations
        List<Ordinate> requestLocations = compatibleRequests.stream()
                .map(com.vitaflow.entities.BloodRequest::getOrdinate)
                .collect(Collectors.toList());

        // 4. Get Distances
        List<Double> distances = googleDistanceService.getDistances(donorLocation, requestLocations);

        // 5. Filter by Distance (5km limit)
        List<RequestDistance> requestDistances = new ArrayList<>();
        for (int i = 0; i < compatibleRequests.size(); i++) {
            double dist = distances.get(i);
            if (dist <= 5.0) { 
                requestDistances.add(new RequestDistance(compatibleRequests.get(i), dist));
            }
        }
        
        // 6. Sort by distance
        requestDistances.sort(Comparator.comparingDouble(RequestDistance::getDistance));
        
        List<com.vitaflow.entities.BloodRequest> result = requestDistances.stream()
                .map(RequestDistance::getRequest)
                .collect(Collectors.toList());

        // 7. Populate Hospital Name (which is stored in Doctor entity)
        for (com.vitaflow.entities.BloodRequest req : result) {
            if (req.getHospitalId() != null) {
                // hospitalId in BloodRequest actually stores the Doctor's userId
                try {
                    doctorRepository.findById(req.getHospitalId()).ifPresent(doctor -> {
                        req.setHospitalName(doctor.getHospitalName());
                    });
                } catch (Exception e) {
                    System.out.println("Error fetching doctor for hospitalId: " + req.getHospitalId() + " - " + e.getMessage());
                }
            }
        }
        
        return result;
    }

    @Autowired
    private com.vitaflow.repositories.RiderRepository riderRepository;    

    public List<com.vitaflow.entities.BloodRequest> findNearbyRequestsForRider(String riderId) {
        // 1. Fetch Rider and Location
        com.vitaflow.entities.user.Rider rider = riderRepository.findById(riderId).orElse(null);
        if (rider == null || rider.getOrdinate() == null) {
            throw new RuntimeException("Rider not found or location not set");
        }
        Ordinate riderLocation = rider.getOrdinate();

        // 2. Fetch all ACCEPTED requests
        List<com.vitaflow.entities.BloodRequest> acceptedRequests = bloodRequestRepository.findByStatus("ACCEPTED");
        
        List<com.vitaflow.entities.BloodRequest> nearbyRequests = new ArrayList<>();

        // 3. Filter: Rider must be close to BOTH Hospital AND Pickup Location (within 5km each)
        // Note: This logic assumes the Rider wants tasks where they are currently somewhat in the middle or close to start points.
        // User Request: "rider distance is less 5km from both reqest location and donor location"
        
        for (com.vitaflow.entities.BloodRequest req : acceptedRequests) {
            if (req.getOrdinate() == null || req.getPickupOrdinate() == null) {
                continue; // Skip if locations are missing
            }

            // Calc distance Rider -> Hospital
            double distToHospital = googleDistanceService.calculateDistance(
                riderLocation.getLatitude(), riderLocation.getLongitude(),
                req.getOrdinate().getLatitude(), req.getOrdinate().getLongitude()
            );

            // Calc distance Rider -> Pickup (Donor)
            double distToPickup = googleDistanceService.calculateDistance(
                riderLocation.getLatitude(), riderLocation.getLongitude(),
                req.getPickupOrdinate().getLatitude(), req.getPickupOrdinate().getLongitude()
            );
            
            if (distToHospital <= 5.0 && distToPickup <= 5.0) {
                 // FILTER: Only show if NO RIDER is assigned yet
                 if (req.getRiderId() == null) {
                     // Populate hospital name before adding
                     if (req.getHospitalId() != null) {
                        doctorRepository.findById(req.getHospitalId()).ifPresent(doctor -> {
                            req.setHospitalName(doctor.getHospitalName());
                        });
                     }
                     nearbyRequests.add(req);
                 }
            }
        }
        
        return nearbyRequests;
    }

    private boolean isCompatible(String donorGroup, String requestGroup) {
        // Simple compatibility logic (can be expanded)
        // For now, let's assume exact match or universal donor logic if simple.
        // Or just exact match to be safe for now.
        // "O-" is universal donor. "AB+" is universal recipient.
        
        if (donorGroup == null || requestGroup == null) return false;
        
        // Exact match is always compatible
        if (donorGroup.equalsIgnoreCase(requestGroup)) return true;
        
        return canDonate(donorGroup, requestGroup);
    }
    
    private boolean canDonate(String donor, String recipient) {
        // Simplified Map
        // O- -> All
        // O+ -> O+, A+, B+, AB+
        // A- -> A-, A+, AB-, AB+
        // A+ -> A+, AB+
        // B- -> B-, B+, AB-, AB+
        // B+ -> B+, AB+
        // AB- -> AB-, AB+
        // AB+ -> AB+
        
        if (donor.equals("O-")) return true;
        if (recipient.equals("AB+")) return true;
        
        if (donor.equals("O+")) return (recipient.equals("O+") || recipient.equals("A+") || recipient.equals("B+") || recipient.equals("AB+"));
        if (donor.equals("A-")) return (recipient.equals("A-") || recipient.equals("A+") || recipient.equals("AB-") || recipient.equals("AB+"));
        if (donor.equals("A+")) return (recipient.equals("A+") || recipient.equals("AB+"));
        if (donor.equals("B-")) return (recipient.equals("B-") || recipient.equals("B+") || recipient.equals("AB-") || recipient.equals("AB+"));
        if (donor.equals("B+")) return (recipient.equals("B+") || recipient.equals("AB+"));
        if (donor.equals("AB-")) return (recipient.equals("AB-") || recipient.equals("AB+"));
        
        return false;
    }

    // Helper class
    private static class RequestDistance {
        private final com.vitaflow.entities.BloodRequest request;
        private final double distance;

        public RequestDistance(com.vitaflow.entities.BloodRequest request, double distance) {
            this.request = request;
            this.distance = distance;
        }

        public com.vitaflow.entities.BloodRequest getRequest() {
            return request;
        }

        public double getDistance() {
            return distance;
        }
    }

    // Helper class
    private static class DonorDistance {
        private final Donor donor;
        private final double distance;

        public DonorDistance(Donor donor, double distance) {
            this.donor = donor;
            this.distance = distance;
        }

        public Donor getDonor() {
            return donor;
        }

        public double getDistance() {
            return distance;
        }
    }
}
