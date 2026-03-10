package com.vitaflow.services.impl;

import com.vitaflow.entities.BloodStock;
import com.vitaflow.repositories.BloodStockRepository;
import com.vitaflow.services.BloodStockService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BloodStockServiceImpl implements BloodStockService {

    @Autowired
    private BloodStockRepository stockRepository;

    @Override
    public BloodStock getHospitalStock(String hospitalId) {
        return stockRepository.findByHospitalId(hospitalId).orElse(null);
    }

    @Override
    public BloodStock updateStock(String hospitalId, String bloodGroup, Integer units) {
        Optional<BloodStock> existingOpt = stockRepository.findByHospitalId(hospitalId);
        BloodStock stock;
        
        if (existingOpt.isPresent()) {
            stock = existingOpt.get();
        } else {
            stock = new BloodStock();
            stock.setHospitalId(hospitalId);
        }

        switch (bloodGroup.toUpperCase()) {
            case "A+": stock.setAp(units); break;
            case "A-": stock.setAn(units); break;
            case "B+": stock.setBp(units); break;
            case "B-": stock.setBn(units); break;
            case "AB+": stock.setAbp(units); break;
            case "AB-": stock.setAbn(units); break;
            case "O+": stock.setOp(units); break;
            case "O-": stock.setOn(units); break;
            default: break;
        }
        
        return stockRepository.save(stock);
    }
}
