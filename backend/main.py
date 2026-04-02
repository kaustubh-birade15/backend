from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List
import hashlib

from conditions import DISCLAIMER, URGENT_MESSAGE
from normalizer import normalize_symptom
from predictor import detect_urgent_symptoms
from ml_model import HomeoRecommender

# Database imports
from database import engine, get_db, Base
import models
import schemas
import json

# Create tables if they don't exist
models.Base.metadata.create_all(bind=engine)

# Initialize our ML recommender. This reads the dataset at startup.
recommender = HomeoRecommender(dataset_path="data/final_cleaned_dataset.csv")

app = FastAPI(
    title="MediGuide API",
    description="Prototype symptom checker backend for educational use only",
    version="3.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class SymptomRequest(BaseModel):
    symptoms: List[str]

# --- Helper functions ---

def get_password_hash(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

# --- Auth Routes ---

@app.post("/register", response_model=schemas.PatientResponse)
def register_patient(patient: schemas.PatientCreate, db: Session = Depends(get_db)):
    db_patient = db.query(models.Patient).filter(models.Patient.email == patient.email).first()
    if db_patient:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_pwd = get_password_hash(patient.password)
    new_patient = models.Patient(
        full_name=patient.full_name,
        age=patient.age,
        gender=patient.gender,
        email=patient.email,
        password_hash=hashed_pwd
    )
    db.add(new_patient)
    db.commit()
    db.refresh(new_patient)
    return new_patient

class ConditionsUpdate(BaseModel):
    conditions: str

@app.put("/patient/{patient_id}/conditions")
def update_patient_conditions(patient_id: int, data: ConditionsUpdate, db: Session = Depends(get_db)):
    patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    patient.medical_conditions = data.conditions
    db.commit()
    return {"message": "Conditions updated successfully", "medical_conditions": patient.medical_conditions}

@app.post("/login")
def login_patient(credentials: schemas.PatientLogin, db: Session = Depends(get_db)):
    patient = db.query(models.Patient).filter(models.Patient.email == credentials.email).first()
    if not patient or patient.password_hash != get_password_hash(credentials.password):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    
    return {"message": "Login successful", "patient_id": patient.id, "full_name": patient.full_name}

@app.get("/patient/{patient_id}", response_model=schemas.PatientResponse)
def get_patient(patient_id: int, db: Session = Depends(get_db)):
    patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    return patient

@app.post("/change_password/{patient_id}")
def change_password(patient_id: int, passwords: schemas.PasswordChange, db: Session = Depends(get_db)):
    patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    if patient.password_hash != get_password_hash(passwords.old_password):
        raise HTTPException(status_code=401, detail="Incorrect old password")
        
    patient.password_hash = get_password_hash(passwords.new_password)
    db.commit()
    return {"message": "Password updated successfully"}

# --- Standard Routes ---

@app.get("/")
def home():
    return {
        "message": "MediGuide API is running",
        "version": "3.0.0",
        "note": "Backend powered by NLP and TF-IDF against Homeopathy Dataset"
    }

@app.post("/predict")
def predict(data: SymptomRequest, patient_id: int = None, db: Session = Depends(get_db)):
    raw_symptoms = data.symptoms

    if not raw_symptoms:
        return {
            "input_symptoms": [],
            "normalized_symptoms": [],
            "urgent": False,
            "urgent_symptoms": [],
            "urgent_message": "",
            "predictions": [],
            "disclaimer": DISCLAIMER,
            "message": "No symptoms provided."
        }

    normalized_symptoms = []
    for symptom in raw_symptoms:
        cleaned = normalize_symptom(symptom)
        if cleaned and cleaned not in normalized_symptoms:
            normalized_symptoms.append(cleaned)

    urgent_found = detect_urgent_symptoms(normalized_symptoms)

    # Convert the inputs into a single paragraph for our AI model
    query_text = " ".join(raw_symptoms)
    
    # Query the ML model
    ai_predictions = recommender.predict(query_text, top_k=3)

    result = {
        "input_symptoms": raw_symptoms,
        "normalized_symptoms": normalized_symptoms,
        "urgent": len(urgent_found) > 0,
        "urgent_symptoms": urgent_found,
        "urgent_message": URGENT_MESSAGE if urgent_found else "",
        "predictions": ai_predictions,
        "disclaimer": DISCLAIMER,
        "medical_conditions": ""
    }

    # Save to history if patient_id is provided
    if patient_id:
        patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
        if patient:
            conditions_str = (patient.medical_conditions or "").lower()
            result["medical_conditions"] = patient.medical_conditions

            # Inject safety advice based on medical history
            for pred in result["predictions"]:
                safety_notes = []
                if "diabetes" in conditions_str or "sugar" in conditions_str:
                    safety_notes.append("As you have Diabetes, please ensure you use sugar-free globules or liquid dilutions.")
                if "hypertension" in conditions_str or "bp" in conditions_str:
                    safety_notes.append("Monitor your blood pressure regularly while using any new remedy.")
                if "heart" in conditions_str:
                    safety_notes.append("Consult your cardiologist before starting any alternative treatment.")
                if "asthma" in conditions_str:
                    safety_notes.append("Ensure regular inhaler use is NOT replaced by these remedies.")
                
                if safety_notes:
                    pred["advice"] = " | ".join(safety_notes) + " | " + pred["advice"]

        record = models.MedicalRecord(
            patient_id=patient_id,
            symptoms=json.dumps(raw_symptoms),
            predictions=json.dumps(ai_predictions)
        )
        db.add(record)
        db.commit()

    return result

@app.get("/history/{patient_id}")
def get_patient_history(patient_id: int, db: Session = Depends(get_db)):
    records = db.query(models.MedicalRecord).filter(models.MedicalRecord.patient_id == patient_id).order_by(models.MedicalRecord.id.desc()).all()
    
    # Parse the JSON strings back to objects for the API response
    history = []
    for r in records:
        history.append({
            "id": r.id,
            "timestamp": r.timestamp,
            "symptoms": json.loads(r.symptoms),
            "predictions": json.loads(r.predictions)
        })
    return {"patient_id": patient_id, "history": history}