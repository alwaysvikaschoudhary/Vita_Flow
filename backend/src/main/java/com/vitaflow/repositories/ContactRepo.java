package com.vitaflow.backend.repositories;

import com.vitaflow.backend.entities.Contact;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ContactRepo extends JpaRepository<Contact, String> {
}
