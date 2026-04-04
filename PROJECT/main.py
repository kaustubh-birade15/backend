"""
SmartHomeoAIAdvisor - FastAPI Backend
Run: uvicorn main:app --reload --port 8080
Docs: http://localhost:8080/docs  (auto-generated, interactive!)
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import pandas as pd
import numpy as np
import sqlite3
import json
import os
from typing import List, Optional, Any

# ── App setup ─────────────────────────────────────────────────────────────────
app = FastAPI(
    title="SmartHomeoAIAdvisor API",
    description="Homeopathic remedy suggester based on Allen's Keynotes & Boericke's Materia Medica",
    version="2.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Load dataset ──────────────────────────────────────────────────────────────
BASE_DIR     = os.path.dirname(os.path.abspath(__file__))
DATASET_PATH = os.path.join(BASE_DIR, "SmartHomeoAIAdvisor_Dataset_V2.csv")
DB_PATH      = os.path.join(BASE_DIR, "homeo.db")

try:
    df = pd.read_csv(DATASET_PATH)
    df = df.fillna("")  # ✅ ADD THIS LINE
    df["symptom"]  = df["symptom"].str.strip().str.lower()
    df["severity"] = df["severity"].str.strip().str.lower()  
except FileNotFoundError:
    print("❌ CSV not found! Put SmartHomeoAIAdvisor_Dataset_V2.csv in same folder.")
    df = pd.DataFrame()


# ══════════════════════════════════════════════════════════════════════════════
#  DATABASE SETUP
# ══════════════════════════════════════════════════════════════════════════════

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS patients (
            id                  INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id             TEXT UNIQUE,
            name                TEXT,
            email               TEXT UNIQUE,
            password            TEXT,
            age                 INTEGER,
            gender              TEXT,
            blood_group         TEXT,
            bp_high             INTEGER DEFAULT 0,
            diabetic            INTEGER DEFAULT 0,
            sugar_level         TEXT,
            bp_reading          TEXT,
            allergies           TEXT,
            existing_conditions TEXT,
            current_medications TEXT,
            medical_conditions  TEXT DEFAULT ''
        )
    """)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS consultations (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id        TEXT,
            symptom        TEXT,
            severity       TEXT,
            remedy_name    TEXT,
            potency        TEXT,
            condition      TEXT,
            consult_doctor INTEGER,
            created_at     TEXT DEFAULT (datetime('now'))
        )
    """)
    conn.commit()
    conn.close()
    print("Database ready")

init_db()


# ══════════════════════════════════════════════════════════════════════════════
#  REQUEST / RESPONSE MODELS  (Pydantic)
# ══════════════════════════════════════════════════════════════════════════════

class PatientProfile(BaseModel):
    user_id:              Optional[str] = None
    full_name:            str
    email:                Optional[str] = ""
    password:             Optional[str] = ""
    age:                  int
    gender:               str
    blood_group:          Optional[str] = ""
    bp_high:              bool = False
    diabetic:             bool = False
    sugar_level:          Optional[str] = "normal"
    bp_reading:           Optional[str] = ""
    allergies:            List[str] = []
    existing_conditions:  List[str] = []
    other_conditions:     Optional[str] = "" # Match user's 'other_conditions'
    current_medications:  List[str] = []

class LoginRequest(BaseModel):
    email: str
    password: str

class PasswordChangeRequest(BaseModel):
    old_password: str
    new_password: str

class ConditionUpdateRequest(BaseModel):
    conditions: str

class ConsultRequest(BaseModel):
    user_id:  str
    symptom:  str
    severity: str   # low | moderate | high

class PredictRequest(BaseModel):
    symptoms: List[str]
    severity: Optional[str] = "moderate"

class RemedyRequest(BaseModel):
    symptom:  str
    severity: str
    patient:  Optional[dict] = {}


# ══════════════════════════════════════════════════════════════════════════════
#  HELPER FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════════

def find_row(symptom: str, severity: str):
    """Find matching row in dataset."""
    match = df[(df["symptom"] == symptom) & (df["severity"] == severity)]
    if match.empty:
        match = df[df["symptom"].str.contains(symptom, na=False) & (df["severity"] == severity)]
    return None if match.empty else match.iloc[0].to_dict()


def get_patient_from_db(patient_id: Any):
    """Fetch patient from SQLite."""
    conn = get_db()
    if isinstance(patient_id, int):
        row = conn.execute("SELECT * FROM patients WHERE id = ?", (patient_id,)).fetchone()
    else:
        row = conn.execute("SELECT * FROM patients WHERE user_id = ?", (str(patient_id),)).fetchone()
    conn.close()
    if not row:
        return {}
    patient = dict(row)
    for field in ["allergies", "existing_conditions", "current_medications"]:
        try:
            patient[field] = json.loads(patient.get(field) or "[]")
        except:
            patient[field] = []
    patient["bp_high"]  = bool(patient.get("bp_high", 0))
    patient["diabetic"] = bool(patient.get("diabetic", 0))
    return patient


def build_safety(row: dict, patient: dict) -> dict:
    """Generate personalised safety warnings for this patient."""
    warnings = []
    is_safe  = True

    bp_high   = patient.get("bp_high", False)
    diabetic  = patient.get("diabetic", False)
    allergies = [a.strip().lower() for a in patient.get("allergies", [])]
    age       = patient.get("age", 25)

    bp_note = str(row.get("suitable_for_bp_high", "")).lower()
    if bp_high:
        if "caution" in bp_note:
            warnings.append("⚠️ CAUTION: High BP patient — consult your homeopathic doctor before use.")
        elif "specifically indicated" in bp_note:
            warnings.append("✅ This remedy is specifically beneficial for high BP patients.")
        elif "not relevant" not in bp_note and "emergency" not in bp_note:
            warnings.append("✅ Safe for high BP patients.")

    dm_note = str(row.get("suitable_for_diabetic", "")).lower()
    if diabetic:
        if "caution" in dm_note or "monitor" in dm_note:
            warnings.append("⚠️ CAUTION: Diabetic patient — monitor blood sugar while using this remedy.")
        elif "specifically indicated" in dm_note:
            warnings.append("✅ This remedy is specifically beneficial for diabetic patients.")
        elif "not relevant" not in dm_note and "emergency" not in dm_note:
            warnings.append("✅ Safe for diabetic patients.")

    avoid_allergy = str(row.get("avoid_if_allergy", "")).lower()
    if allergies and avoid_allergy not in ["none", "nan", ""]:
        for allergy in allergies:
            if allergy in avoid_allergy:
                warnings.append(f"🚨 ALLERGY ALERT: You listed '{allergy}' — consult doctor before taking this.")
                is_safe = False

    age_group = str(row.get("patient_age_group", "all")).lower()
    if age < 12 and age_group == "adult":
        warnings.append("⚠️ This remedy is for adults — consult a doctor for child dosage.")
    if age > 65 and "child" in age_group:
        warnings.append("ℹ️ This remedy is typically for children — adult dosing may differ.")

    return {"is_safe": is_safe, "warnings": warnings}


def build_response(row: dict, patient: dict, symptom: str, severity: str) -> dict:
    safety = build_safety(row, patient)
    
    # Matching the screenshot structure exactly
    remedy_data = {
        "name":               str(row.get("remedy_name", "")),
        "potency":            str(row.get("potency", "")),
        "possible_condition": str(row.get("possible_condition", "")),
        "keynote":            str(row.get("keynote_indication", "")),
        "why_this_remedy":    str(row.get("remedy_reason", "")),
        "source_book":        str(row.get("source_book", "")),
        "additional_notes":   str(row.get("additional_notes", ""))
    }

    patient_safety = {
        "is_safe":       bool(safety["is_safe"]),
        "warnings":      [str(w) for w in safety["warnings"]] if safety["warnings"] else ["✅ This remedy is suitable for your health profile. Take as directed."],
        "bp_note":       str(row.get("suitable_for_bp_high", "Safe for BP")),
        "diabetes_note": str(row.get("suitable_for_diabetic", "Safe for Diabetics")),
        "allergy_note":  str(row.get("avoid_if_allergy", "No known allergies"))
    }

    return {
        "success": True,
        "query": {
            "symptom":      str(symptom),
            "severity":     str(severity),
            "patient_name": str(patient.get("name", "Patient")),
        },
        "remedy": remedy_data,
        "patient_safety": patient_safety,
        "predictions": [remedy_data], # Keep this for list-based UI compatibility
        "disclaimer": "⚠️ Recommendations are AI-generated based on homeopathic principles. Consult a professional doctor before starting treatment.",
        "urgent": bool(str(row.get("consult_doctor", "no")).strip().lower() == "yes"),
        "urgent_message": "🚨 URGENT: Symptoms may require professional medical intervention. Consult a doctor immediately."
    }

# ══════════════════════════════════════════════════════════════════════════════
#  ENDPOINTS
# ══════════════════════════════════════════════════════════════════════════════

@app.get("/")
def health():
    return {
        "status":  "SmartHomeoAIAdvisor is running!",
        "version": "2.0",
        "dataset": f"{len(df)} remedy rows loaded",
        "docs":    "http://localhost:8080/docs"
    }


@app.get("/symptoms")
def get_symptoms():
    """Get all available symptoms for Flutter dropdown."""
    if df.empty:
        raise HTTPException(status_code=500, detail="Dataset not loaded")
    symptoms = sorted(df["symptom"].unique().tolist())
    return {"total": len(symptoms), "symptoms": symptoms}


@app.get("/symptoms/all")
def get_symptoms_with_severities():
    """Get symptoms with their available severity levels."""
    if df.empty:
        raise HTTPException(status_code=500, detail="Dataset not loaded")
    result = {}
    for symptom in sorted(df["symptom"].unique()):
        result[symptom] = sorted(df[df["symptom"] == symptom]["severity"].unique().tolist())
    return {"total": len(result), "symptoms": result}


@app.post("/register")
@app.post("/patient/register")
def register_patient(patient: PatientProfile):
    """Save patient profile after signup."""
    conn = get_db()
    try:
        uid = patient.user_id or patient.email
        
        cursor = conn.execute("""
            INSERT OR REPLACE INTO patients
                (user_id, name, email, password, age, gender, blood_group, bp_high, diabetic,
                 sugar_level, bp_reading, allergies, existing_conditions, current_medications, medical_conditions)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        """, (
            uid, patient.full_name, patient.email, patient.password, patient.age, patient.gender,
            patient.blood_group, int(patient.bp_high), int(patient.diabetic),
            patient.sugar_level, patient.bp_reading,
            json.dumps(patient.allergies),
            json.dumps(patient.existing_conditions),
            json.dumps(patient.current_medications),
            patient.other_conditions or ""
        ))
        conn.commit()
        
        # Correctly fetch the internal database ID after UPSERT
        res = conn.execute("SELECT id FROM patients WHERE email=?", (patient.email,)).fetchone()
        p_id = res[0] if res else 0

        return {
            "success": True, 
            "id": p_id,
            "patient_id": p_id,
            "name": patient.full_name,
            "email": patient.email
        }
    except Exception as e:
        print("Register Error:", e)
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()


@app.post("/login")
def login(req: LoginRequest):
    conn = get_db()
    row = conn.execute("SELECT * FROM patients WHERE email = ? AND password = ?", (req.email, req.password)).fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    patient = dict(row)
    return {
        "success": True,
        "message": "Login successful",
        "id": patient["id"],
        "patient_id": patient["id"],
        "name": patient["name"],
        "email": patient["email"],
        "age": patient["age"],
        "gender": patient["gender"]
    }


@app.get("/patient/{patient_id}")
def get_patient(patient_id: str):
    """Get patient profile by patient_id or user_id."""
    try:
        p_id = int(patient_id)
    except:
        p_id = patient_id
    patient = get_patient_from_db(p_id)
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    return {"success": True, "patient": patient}


@app.put("/patient/{patient_id}/conditions")
def update_conditions(patient_id: str, req: ConditionUpdateRequest):
    try:
        p_id = int(patient_id)
        column = "id"
    except:
        p_id = patient_id
        column = "user_id"
        
    conn = get_db()
    conn.execute(f"UPDATE patients SET medical_conditions = ? WHERE {column} = ?", (req.conditions, p_id))
    conn.commit()
    conn.close()
    return {"success": True, "message": "Conditions updated"}


@app.post("/change_password/{patient_id}")
def change_password(patient_id: str, req: PasswordChangeRequest):
    try:
        p_id = int(patient_id)
        column = "id"
    except:
        p_id = patient_id
        column = "user_id"

    conn = get_db()
    row = conn.execute(f"SELECT password FROM patients WHERE {column} = ?", (p_id,)).fetchone()
    if not row or row[0] != req.old_password:
        conn.close()
        raise HTTPException(status_code=400, detail="Incorrect old password")
    
    conn.execute(f"UPDATE patients SET password = ? WHERE {column} = ?", (req.new_password, p_id))
    conn.commit()
    conn.close()
    return {"success": True, "message": "Password updated"}


def run_analysis(symptom: str, severity: str, user_id: str = "guest"):
    if df.empty:
        raise HTTPException(status_code=500, detail="Dataset not loaded")
    
    severity = severity.lower().strip() if severity else "moderate"
    if severity not in ["low", "moderate", "high"]:
        raise HTTPException(status_code=400, detail="severity must be: low / moderate / high")

    patient = get_patient_from_db(user_id)
    row = find_row(symptom, severity)

    if row is None:
        available = sorted(df[df["severity"] == severity]["symptom"].unique().tolist())
        raise HTTPException(
            status_code=404,
            detail={"error": f"No remedy found for '{symptom}' at '{severity}'",
                    "available_symptoms": available}
        )

    conn = get_db()
    conn.execute("""
        INSERT INTO consultations (user_id, symptom, severity, remedy_name, potency, condition, consult_doctor)
        VALUES (?,?,?,?,?,?,?)
    """, (
        user_id, symptom, severity,
        row.get("remedy_name", ""), row.get("potency", ""),
        row.get("possible_condition", ""),
        1 if str(row.get("consult_doctor", "no")).strip().lower() == "yes" else 0
    ))
    conn.commit()
    conn.close()

    return build_response(row, patient, symptom, severity)


@app.post("/predict")
def predict_endpoint(req: PredictRequest, patient_id: Optional[str] = None):
    user_id = "guest"
    if patient_id:
        try:
            p_id = int(patient_id)
            p = get_patient_from_db(p_id)
            if p: user_id = p["user_id"]
        except:
            user_id = patient_id
            
    if not req.symptoms:
        raise HTTPException(status_code=400, detail="Symptoms list empty")
    
    symptom = req.symptoms[0].strip().lower()
    return run_analysis(symptom, req.severity, user_id)


@app.post("/consult")
def consult_endpoint(req: ConsultRequest):
    return run_analysis(req.symptom.strip().lower(), req.severity.strip().lower(), req.user_id)


@app.get("/history/{patient_id}")
def get_history(patient_id: str):
    """Get last 20 consultations for a user."""
    try:
        p_id = int(patient_id)
    except:
        p_id = patient_id
        
    patient = get_patient_from_db(p_id)
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    user_id = patient["user_id"]
    conn = get_db()
    rows = conn.execute("""
        SELECT * FROM consultations WHERE user_id = ?
        ORDER BY created_at DESC LIMIT 20
    """, (user_id,)).fetchall()
    conn.close()
    return {
        "success":      True,
        "patient_name": patient.get("name"),
        "total":        len(rows),
        "history":      [dict(r) for r in rows]
    } 
 
