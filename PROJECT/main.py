"""
SmartHomeoAIAdvisor - Professional Cloud Backend (PostgreSQL)
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Any
import pandas as pd
import numpy as np
import psycopg2
from psycopg2.extras import RealDictCursor
from sqlalchemy import create_engine, text
import json
import os

# â”€â”€ Cloud Database Setup â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
DATABASE_URL = "postgresql://neondb_owner:npg_7y0ZlucUKBQM@ep-divine-cherry-a46quzq0-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require"
engine = create_engine(DATABASE_URL)

def get_db():
    return psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)

def init_db():
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS patients (
                id                  SERIAL PRIMARY KEY,
                user_id             TEXT UNIQUE,
                full_name           TEXT,
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
                medical_conditions  TEXT,
                created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """))
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS consultations (
                id                  SERIAL PRIMARY KEY,
                user_id             TEXT,
                symptom             TEXT,
                severity            TEXT,
                remedy_name         TEXT,
                potency             TEXT,
                condition           TEXT,
                consult_doctor      INTEGER,
                created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """))
        conn.commit()

init_db()

# â”€â”€ App setup â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
app = FastAPI(title="SmartHomeoAIAdvisor API", version="3.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"],)

# â”€â”€ Load dataset â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
BASE_DIR     = os.path.dirname(os.path.abspath(__file__))
DATASET_PATH = os.path.join(BASE_DIR, "SmartHomeoAIAdvisor_Dataset_V2.csv")
try:
    df = pd.read_csv(DATASET_PATH).fillna("")
    df["symptom"]  = df["symptom"].str.strip().str.lower()
    df["severity"] = df["severity"].str.strip().str.lower()  
except:
    df = pd.DataFrame()

# â”€â”€ Models â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class PatientProfile(BaseModel):
    user_id: Optional[str] = None; full_name: str; email: str = ""; password: str = ""
    age: int; gender: str; blood_group: str = ""; bp_high: bool = False
    diabetic: bool = False; sugar_level: str = "normal"; bp_reading: str = ""
    allergies: List[str] = []; existing_conditions: List[str] = []; other_conditions: str = ""
    current_medications: List[str] = []

class LoginRequest(BaseModel): email: str; password: str
class PredictRequest(BaseModel): symptoms: List[str]; severity: str = "moderate"

# â”€â”€ AI LOGIC HELPERS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def get_patient_info(pid: Any):
    conn = get_db()
    with conn.cursor() as cur:
        if isinstance(pid, int): cur.execute("SELECT * FROM patients WHERE id = %s", (pid,))
        else: cur.execute("SELECT * FROM patients WHERE user_id = %s", (str(pid),))
        row = cur.fetchone()
    conn.close()
    if not row: return {}
    p = dict(row)
    for f in ["allergies", "existing_conditions", "current_medications"]:
        try: p[f] = json.loads(p.get(f) or "[]")
        except: p[f] = []
    return p

def build_safety(row: dict, p: dict):
    warnings = []
    if p.get("bp_high") and "caution" in str(row.get("suitable_for_bp_high", "")).lower():
        warnings.append("âš ï¸ High BP Warning: Consult doctor before use.")
    if p.get("diabetic") and "caution" in str(row.get("suitable_for_diabetic", "")).lower():
        warnings.append("âš ï¸ Diabetes Warning: Monitor sugar levels.")
    return warnings or ["âœ… Safe for your medical profile."]

# â”€â”€ ENDPOINTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
@app.get("/")
def health(): return {"status": "Live on Neon Cloud", "rows": len(df)}

@app.post("/register")
@app.post("/patient/register")
def register(p: PatientProfile):
    conn = get_db()
    uid = p.user_id or p.email
    try:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO patients (user_id, full_name, email, password, age, gender, blood_group, bp_high, diabetic, sugar_level, bp_reading, allergies, existing_conditions, current_medications, medical_conditions)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
                ON CONFLICT (email) DO UPDATE SET 
                    full_name=EXCLUDED.full_name, 
                    age=EXCLUDED.age,
                    gender=EXCLUDED.gender,
                    bp_high=EXCLUDED.bp_high,
                    diabetic=EXCLUDED.diabetic,
                    sugar_level=EXCLUDED.sugar_level,
                    allergies=EXCLUDED.allergies,
                    existing_conditions=EXCLUDED.existing_conditions,
                    medical_conditions=EXCLUDED.medical_conditions
                RETURNING id
            """, (uid, p.full_name, p.email, p.password, p.age, p.gender, p.blood_group, int(p.bp_high), int(p.diabetic), p.sugar_level, p.bp_reading, json.dumps(p.allergies), json.dumps(p.existing_conditions), json.dumps(p.current_medications), p.other_conditions))
            conn.commit()
            result = cur.fetchone()
            pid = result["id"] if result else 0
        return {"success": True, "id": pid, "patient_id": pid, "name": p.full_name}
    finally: conn.close()

@app.post("/login")
def login(req: LoginRequest):
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM patients WHERE email = %s AND password = %s", (req.email, req.password))
        row = cur.fetchone()
    if not row: raise HTTPException(401, "Invalid credentials")
    return {"success": True, "id": row["id"], "patient_id": row["id"], "name": row["full_name"]}

@app.get("/patient/{patient_id}")
def getp(patient_id: str):
    try: pid = int(patient_id)
    except: pid = patient_id
    p = get_patient_info(pid)
    if not p: raise HTTPException(404, "Not found")
    return {"success": True, "patient": p}

@app.post("/predict")
def predict(req: PredictRequest, patient_id: Optional[str] = None):
    sym = req.symptoms[0].lower().strip()
    match = df[(df["symptom"] == sym) & (df["severity"] == req.severity.lower())]
    if match.empty: raise HTTPException(404, "No remedy found")
    row = match.iloc[0].to_dict()
    p = get_patient_info(patient_id) if patient_id else {}
    
    # Storage
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("INSERT INTO consultations (user_id, symptom, severity, remedy_name, potency, condition) VALUES (%s,%s,%s,%s,%s,%s)",(patient_id or "guest", sym, req.severity, row["remedy_name"], row["potency"], row["possible_condition"]))
        conn.commit()
    conn.close()

    return {
        "success": True,
        "remedy": {
            "name": row["remedy_name"], "potency": row["potency"], 
            "keynote": row["keynote_indication"], "why_this_remedy": row["remedy_reason"],
            "possible_condition": row["possible_condition"], "source_book": row.get("source_book", ""),
            "additional_notes": row.get("additional_notes", "")
        },
        "patient_safety": {"warnings": build_safety(row, p)},
        "disclaimer": "âš ï¸ AI-generated homeopathic advice. Consult a doctor."
    }

@app.get("/history/{patient_id}")
def geth(patient_id: str):
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM consultations WHERE user_id = %s ORDER BY created_at DESC LIMIT 20", (patient_id,))
        rows = cur.fetchall()
    return {"success": True, "history": rows}
