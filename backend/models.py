from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
import datetime

from database import Base

class Patient(Base):
    __tablename__ = "patients"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, index=True)
    age = Column(Integer)
    gender = Column(String)
    email = Column(String, unique=True, index=True)
    password_hash = Column(String)
    medical_conditions = Column(String, default="") # Store as comma-separated or JSON string

    # Relationships
    records = relationship("MedicalRecord", back_populates="patient")


class MedicalRecord(Base):
    __tablename__ = "medical_records"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id"))
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    
    # Store JSON strings for simplicity in SQLite 
    symptoms = Column(String) # List of input symptoms
    predictions = Column(String) # Suggested remedies

    patient = relationship("Patient", back_populates="records")
