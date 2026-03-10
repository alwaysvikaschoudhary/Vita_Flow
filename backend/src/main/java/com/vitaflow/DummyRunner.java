package com.vitaflow;

import com.vitaflow.entities.BloodStock;
import com.vitaflow.repositories.BloodStockRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class DummyRunner implements CommandLineRunner {

    @Autowired
    private BloodStockRepository stockRepo;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("----- STARTING STOCK DUMP -----");
        List<BloodStock> stocks = stockRepo.findAll();
        System.out.println("TOTAL STOCKS COUNT: " + stocks.size());
        for (BloodStock s : stocks) {
            System.out.println("STOCK ROW: " + s.getHospitalId() + " -> " + s.getAp());
        }
        System.out.println("----- ENDING STOCK DUMP -----");
    }
}
