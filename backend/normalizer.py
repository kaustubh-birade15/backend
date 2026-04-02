SYMPTOM_ALIASES = {
    "high temperature": "fever",
    "temperature": "fever",
    "body temperature": "fever",
    "cold": "runny nose",
    "blocked nose": "nasal congestion",
    "stuffy nose": "nasal congestion",
    "sneezing a lot": "sneezing",
    "throwing up": "vomiting",
    "vomit": "vomiting",
    "head pain": "headache",
    "stomach pain": "abdominal pain",
    "belly pain": "abdominal pain",
    "loose motions": "diarrhea",
    "tiredness": "fatigue",
    "weakness": "fatigue",
    "throat pain": "sore throat",
    "burning in chest": "acidity",
    "heart burn": "acidity",
    "trouble breathing": "breathing difficulty",
    "breathlessness": "shortness of breath",
    "fainting": "unconsciousness",
    "bloody stool": "blood in stool",
    "bloody vomit": "blood in vomit",
    "pain in chest": "chest pain",
    "dry throat cough": "dry cough",
    "body pain": "body ache",
}


def normalize_symptom(symptom: str) -> str:
    symptom = symptom.strip().lower()
    return SYMPTOM_ALIASES.get(symptom, symptom)