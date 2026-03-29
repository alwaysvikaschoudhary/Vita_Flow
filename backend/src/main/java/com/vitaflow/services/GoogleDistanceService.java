package com.vitaflow.services;

import com.vitaflow.entities.Ordinate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class GoogleDistanceService {

    /**
     * Calculates distance using Haversine formula instead of Google API.
     * Returned distance is in KM.
     */
    public List<Double> getDistances(Ordinate origin, List<Ordinate> destinations) {
        if (destinations == null || destinations.isEmpty()) {
            return java.util.Collections.emptyList();
        }

        return destinations.stream()
                .map(dest -> calculateHaversineDistance(origin, dest))
                .collect(Collectors.toList());
    }

    private double calculateHaversineDistance(Ordinate origin, Ordinate dest) {
        if (origin == null || dest == null || origin.getLatitude() == null || origin.getLongitude() == null || dest.getLatitude() == null || dest.getLongitude() == null) {
            return Double.MAX_VALUE;
        }

        return calculateDistance(
            origin.getLatitude(), origin.getLongitude(),
            dest.getLatitude(), dest.getLongitude()
        );
    }

    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double R = 6371; // Earth radius in KM
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
