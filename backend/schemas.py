from pydantic import BaseModel, EmailStr
from typing import List, Optional
import datetime

# --- Medical Record Schemas ---
class MedicalRecordBase(BaseModel):
    symptoms: str
    predictions: str

class MedicalRecordCreate(MedicalRecordBase):
    pass

class MedicalRecordResponse(MedicalRecordBase):
    id: int
    patient_id: int
    timestamp: datetime.datetime

    class Config:
        orm_mode = True

# --- Patient Schemas ---
class PatientBase(BaseModel):
    full_name: str
    age: int
    gender: str
    email: EmailStr
    medical_conditions: Optional[str] = ""

class PatientCreate(PatientBase):
    password: str

class PatientLogin(BaseModel):
    email: EmailStr
    password: str

class PasswordChange(BaseModel):
    old_password: str
    new_password: str

class PatientResponse(PatientBase):
    id: int
    records: List[MedicalRecordResponse] = []

    class Config:
        orm_mode = True
