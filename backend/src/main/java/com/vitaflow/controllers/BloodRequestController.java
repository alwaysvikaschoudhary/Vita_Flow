package com.vitaflow.controllers;

import com.vitaflow.entities.BloodRequest;
import com.vitaflow.services.BloodRequestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/request")
@CrossOrigin(originPatterns = "*")
public class BloodRequestController {

    @Autowired
    private BloodRequestService requestService;

    @Autowired
    private com.vitaflow.services.MatchingService matchingService;

    @PostMapping("/create")
    public ResponseEntity<?> createRequest(@RequestBody BloodRequest request) {
        try {
            // Set default date/time if not provided
            if (request.getDate() == null) {
                request.setDate(LocalDate.now().toString());
            }
            if (request.getTime() == null) {
                request.setTime(LocalTime.now().toString());
            }
            // Default status
            if (request.getStatus() == null) {
                request.setStatus("PENDING");
            }
            
            BloodRequest savedRequest = requestService.createRequest(request);
            
            return ResponseEntity.ok(Map.of(
                "message", "Request created successfully", 
                "request", savedRequest
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/list")
    public ResponseEntity<List<BloodRequest>> getAllRequests() {
        return ResponseEntity.ok(requestService.getAllRequests());
    }

    @GetMapping("/hospital/{hospitalId}")
    public ResponseEntity<List<BloodRequest>> getRequestsByHospital(@PathVariable String hospitalId) {
        return ResponseEntity.ok(requestService.getRequestsByHospital(hospitalId));
    }

    @Autowired
    private com.vitaflow.repositories.DonorRepository donorRepository;

    @GetMapping("/nearby/{donorId}")
    public ResponseEntity<?> getNearbyRequestsForDonor(@PathVariable String donorId) {
         com.vitaflow.entities.user.Donor donor = donorRepository.findById(donorId).orElse(null);
         if (donor == null || donor.getOrdinate() == null) {
             return ResponseEntity.badRequest().body(Map.of("error", "Donor not found or location not set"));
         }
         
         List<BloodRequest> nearby = matchingService.findNearbyRequests(donor.getBloodGroup(), donor.getOrdinate());
         return ResponseEntity.ok(nearby);
    }
    @PostMapping("/accept/{requestId}")
    public ResponseEntity<?> acceptRequest(@PathVariable String requestId, @RequestBody Map<String, Object> payload) {
        try {
            String donorId = (String) payload.get("donorId");
            String donorName = (String) payload.get("donorName");
            Double latitude = payload.get("latitude") != null ? Double.valueOf(payload.get("latitude").toString()) : null;
            Double longitude = payload.get("longitude") != null ? Double.valueOf(payload.get("longitude").toString()) : null;

            BloodRequest acceptedRequest = requestService.acceptRequest(requestId, donorId, donorName, latitude, longitude);
            
             // Fetch donor to get phone number
            com.vitaflow.entities.user.Donor donor = donorRepository.findById(donorId).orElse(null);
            if (donor != null && acceptedRequest != null) {
                acceptedRequest.setDonorPhoneNumber(donor.getPhoneNumber());
                requestService.createRequest(acceptedRequest); // Save again with phone number
            }

            return ResponseEntity.ok(acceptedRequest);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/rider/nearby/{riderId}")
    public ResponseEntity<?> getNearbyRequestsForRider(@PathVariable String riderId) {
        try {
            List<BloodRequest> nearby = matchingService.findNearbyRequestsForRider(riderId);
            return ResponseEntity.ok(nearby);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/active/donor/{donorId}")
    public ResponseEntity<?> getActiveDonorRequests(@PathVariable String donorId) {
        try {
            List<BloodRequest> activeRequests = requestService.findActiveRequestsForDonor(donorId);
            return ResponseEntity.ok(activeRequests);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/history/donor/{donorId}")
    public ResponseEntity<?> getDonorHistory(@PathVariable String donorId) {
        try {
            List<BloodRequest> history = requestService.findHistoryForDonor(donorId);
            return ResponseEntity.ok(history);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/{requestId}")
    public ResponseEntity<?> getRequestById(@PathVariable String requestId) {
        BloodRequest request = requestService.getRequestById(requestId);
        if (request != null) {
            return ResponseEntity.ok(request);
        } else {
             return ResponseEntity.notFound().build();
        }
    }

    @Autowired
    private com.vitaflow.services.UserService userService;

    @PostMapping("/assign/rider")
    public ResponseEntity<?> assignRider(@RequestBody Map<String, String> payload) {
        try {
            String requestId = payload.get("requestId");
            String riderId = payload.get("riderId");
            String riderName = payload.get("riderName");

            BloodRequest request = requestService.getRequestById(requestId);
            if (request == null) return ResponseEntity.badRequest().body(Map.of("error", "Request not found"));
            
            request.setRiderId(riderId);
            request.setRiderName(riderName);
            request.setStatus("RIDER_ASSIGNED"); // Or ON_THE_WAY_TO_DONOR
            
            com.vitaflow.entities.user.Rider rider = userService.getRiderById(riderId);
            if (rider != null) {
                request.setRiderPhoneNumber(rider.getPhoneNumber());
                request.setRiderBikeNumber(rider.getBikeNumber());
            }
            
            BloodRequest updatedRequest = requestService.createRequest(request);
            return ResponseEntity.ok(updatedRequest);
        } catch (Exception e) {
             return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/pickup/verify")
    public ResponseEntity<?> verifyPickupOtp(@RequestBody Map<String, String> payload) {
        try {
            String requestId = payload.get("requestId");
            String otp = payload.get("otp");

            BloodRequest request = requestService.getRequestById(requestId);
            if (request == null) return ResponseEntity.badRequest().body(Map.of("error", "Request not found"));

            if ("PICKED_UP".equals(request.getStatus())) {
                 return ResponseEntity.ok(Map.of("message", "Request is already picked up", "request", request));
            }

            if (request.getOtp() != null && request.getOtp().equals(otp)) {
                request.setStatus("PICKED_UP");
                BloodRequest updatedRequest = requestService.createRequest(request);
                
                // Increment Donor Donation Count
                if (updatedRequest.getDonorId() != null) {
                    com.vitaflow.entities.user.Donor donor = donorRepository.findById(updatedRequest.getDonorId()).orElse(null);
                    if (donor != null) {
                        try {
                            int count = donor.getNumberOfDonation() != null ? Integer.parseInt(donor.getNumberOfDonation()) : 0;
                            donor.setNumberOfDonation(String.valueOf(count + 1));
                            donor.setLastDonationDate(LocalDate.now().toString());
                            donorRepository.save(donor);
                        } catch (NumberFormatException e) {
                            // Handle case where it might not be a number
                             donor.setNumberOfDonation("1");
                             donorRepository.save(donor);
                        }
                    }
                }

                return ResponseEntity.ok(Map.of("message", "OTP Verified", "request", updatedRequest));
            } else {
                return ResponseEntity.badRequest().body(Map.of("error", "Invalid OTP"));
            }
        } catch (Exception e) {
             return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/complete")
    public ResponseEntity<?> completeRequest(@RequestBody Map<String, String> payload) {
        try {
            String requestId = payload.get("requestId");
            BloodRequest request = requestService.getRequestById(requestId);
            if (request == null) return ResponseEntity.badRequest().body(Map.of("error", "Request not found"));

            request.setStatus("COMPLETED");
            BloodRequest updatedRequest = requestService.createRequest(request);
            
            // Increment Rider Deliveries
            if (updatedRequest.getRiderId() != null) {
                com.vitaflow.entities.user.Rider rider = userService.getRiderById(updatedRequest.getRiderId());
                if (rider != null) {
                    try {
                        int count = rider.getTotalDeliveries() != null ? Integer.parseInt(rider.getTotalDeliveries()) : 0;
                        rider.setTotalDeliveries(String.valueOf(count + 1));
                        userService.saveRider(rider);
                    } catch (NumberFormatException e) {
                        rider.setTotalDeliveries("1");
                        userService.saveRider(rider);
                    }
                }
            }
            
            return ResponseEntity.ok(updatedRequest);
        } catch (Exception e) {
             return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/rider/active/{riderId}")
    public ResponseEntity<?> getActiveRiderRequest(@PathVariable String riderId) {
        try {
            // Find requests for this rider that are NOT completed or pending (i.e., ASSIGNED or PICKED_UP)
            List<BloodRequest> allRequests = requestService.getAllRequests(); // Should ideally use a custom query
            BloodRequest active = allRequests.stream()
                .filter(r -> riderId.equals(r.getRiderId()))
                .filter(r -> "RIDER_ASSIGNED".equals(r.getStatus()) || "PICKED_UP".equals(r.getStatus()) || "ON_THE_WAY".equals(r.getStatus()))
                .findFirst()
                .orElse(null);
            
            if (active != null) {
                 // Populate hospital name
                 if (active.getHospitalId() != null) {
                     // Using donorRepository here because Hospital might be stored as Doctor
                     // In MatchingService we used doctorRepository. 
                     // Let's assume DoctorRepository is needed. 
                     // We don't have it injected here yet? matchesService has it.
                     // requestService methods usually don't populate transient fields unless explicitly done.
                 }
                 // Return the active request
                 return ResponseEntity.ok(active);
            } else {
                return ResponseEntity.noContent().build();
            }
        } catch (Exception e) {
             return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/rider/location")
    public ResponseEntity<?> updateRiderLocation(@RequestBody Map<String, Object> payload) {
        try {
            String requestId = (String) payload.get("requestId");
            Double latitude = ((Number) payload.get("latitude")).doubleValue();
            Double longitude = ((Number) payload.get("longitude")).doubleValue();

            BloodRequest request = requestService.getRequestById(requestId);
            if (request == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "Request not found"));
            }

            String riderId = request.getRiderId();
            if (riderId == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "No rider assigned to this request"));
            }

            // We need to fetch the rider first to get their phone number which is used as ID in updateUserLocation
            // OR we can just use a helper in UserService to update by ID.
            // But UserService.updateUserLocation takes phoneNumber.
            // Let's rely on finding the rider entity directly.
            com.vitaflow.entities.user.Rider rider = userService.getRiderById(riderId);
            if (rider != null) {
                userService.updateUserLocation(rider.getPhoneNumber(), new com.vitaflow.payload.LocationDTO(latitude, longitude));
                return ResponseEntity.ok(Map.of("message", "Location updated successfully"));
            } else {
                return ResponseEntity.badRequest().body(Map.of("error", "Rider not found"));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
