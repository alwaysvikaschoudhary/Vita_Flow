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
    private DonorRepository donorRepository;

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
