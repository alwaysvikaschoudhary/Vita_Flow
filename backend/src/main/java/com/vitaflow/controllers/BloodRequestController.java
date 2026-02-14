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
            return ResponseEntity.ok(Map.of("message", "Request created successfully", "request", savedRequest));
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
}
