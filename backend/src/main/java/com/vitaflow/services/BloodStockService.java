package com.vitaflow.services;

import com.vitaflow.entities.BloodStock;
import java.util.List;

public interface BloodStockService {
    BloodStock getHospitalStock(String hospitalId);
    BloodStock updateStock(String hospitalId, String bloodGroup, Integer units);
}
