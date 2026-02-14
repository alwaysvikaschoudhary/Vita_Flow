package com.vitaflow.services;

import com.vitaflow.entities.Ordinate;
import com.vitaflow.payload.LocationDTO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class GoogleDistanceService {

    @Value("${google.maps.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private static final String DISTANCE_MATRIX_API_URL = "https://maps.googleapis.com/maps/api/distancematrix/json";

    public List<Double> getDistances(Ordinate origin, List<Ordinate> destinations) {
        if (destinations == null || destinations.isEmpty()) {
            return Collections.emptyList();
        }

        String destinationsString = destinations.stream()
                .map(ord -> ord.getLatitude() + "," + ord.getLongitude())
                .collect(Collectors.joining("|"));

        String originString = origin.getLatitude() + "," + origin.getLongitude();

        String url = UriComponentsBuilder.fromUriString(DISTANCE_MATRIX_API_URL)
                .queryParam("origins", originString)
                .queryParam("destinations", destinationsString)
                .queryParam("key", apiKey)
                .toUriString();

        try {
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            
            if (response != null && "OK".equals(response.get("status"))) {
                List<Map<String, Object>> rows = (List<Map<String, Object>>) response.get("rows");
                if (rows != null && !rows.isEmpty()) {
                    List<Map<String, Object>> elements = (List<Map<String, Object>>) rows.get(0).get("elements");
                    
                    return elements.stream().map(element -> {
                        if ("OK".equals(element.get("status"))) {
                            Map<String, Object> distanceMap = (Map<String, Object>) element.get("distance");
                            if (distanceMap != null) {
                                Number value = (Number) distanceMap.get("value"); // Value in meters
                                return value.doubleValue() / 1000.0; // Convert to KM
                            }
                        }
                        return Double.MAX_VALUE; // Return max value if unreachable
                    }).collect(Collectors.toList());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Return max values in case of failure to maintain index alignment
        return Collections.nCopies(destinations.size(), Double.MAX_VALUE);
    }
}
