package com.vitaflow.controllers;

import com.vitaflow.entities.BloodStock;
import com.vitaflow.services.BloodStockService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/stock")
public class BloodStockController {

    @Autowired
    private BloodStockService stockService;

    @GetMapping("/{hospitalId}")
    public ResponseEntity<BloodStock> getHospitalStock(@PathVariable String hospitalId) {
        BloodStock stock = stockService.getHospitalStock(hospitalId);
        return ResponseEntity.ok(stock);
    }

    @PostMapping("/update")
    public ResponseEntity<?> updateStock(@RequestBody Map<String, Object> payload) {
        try {
            String hospitalId = (String) payload.get("hospitalId");
            String bloodGroup = (String) payload.get("bloodGroup");
            // Handle both String and Integer depending on JSON library parsing
            Integer units = 0;
            Object unitsObj = payload.get("units");
            if (unitsObj instanceof Integer) {
                units = (Integer) unitsObj;
            } else if (unitsObj instanceof String) {
                units = Integer.parseInt((String) unitsObj);
            }

            BloodStock updatedStock = stockService.updateStock(hospitalId, bloodGroup, units);
            return ResponseEntity.ok(updatedStock);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
