CONDITIONS = [
    {
        "condition": "Common Cold",
        "primary_symptoms": [
            "runny nose",
            "sore throat",
            "sneezing",
            "nasal congestion"
        ],
        "secondary_symptoms": [
            "cough",
            "fatigue",
            "mild fever"
        ],
        "remedy": "Belladonna 30C",
        "description": "A viral upper respiratory condition with congestion, throat irritation, and mild fever.",
        "advice": "Rest, hydrate, and monitor symptoms. Seek medical care if symptoms worsen or breathing becomes difficult."
    },
    {
        "condition": "Flu-like Illness",
        "primary_symptoms": [
            "fever",
            "cough",
            "body ache"
        ],
        "secondary_symptoms": [
            "fatigue",
            "headache",
            "sore throat",
            "chills"
        ],
        "remedy": "Gelsemium 30C",
        "description": "A stronger viral illness often causing fever, weakness, body pain, and headache.",
        "advice": "Rest well, drink fluids, and seek medical help if fever is persistent, severe weakness develops, or breathing issues occur."
    },
    {
        "condition": "Acidity / Indigestion",
        "primary_symptoms": [
            "acidity",
            "bloating",
            "nausea"
        ],
        "secondary_symptoms": [
            "abdominal pain",
            "vomiting",
            "loss of appetite"
        ],
        "remedy": "Nux Vomica 30C",
        "description": "Digestive discomfort often linked with acidity, bloating, nausea, or poor food tolerance.",
        "advice": "Avoid spicy or oily food, stay hydrated, and consult a doctor if pain is severe or persistent."
    },
    {
        "condition": "Food Poisoning / Gastroenteritis",
        "primary_symptoms": [
            "vomiting",
            "diarrhea",
            "abdominal pain"
        ],
        "secondary_symptoms": [
            "nausea",
            "fever",
            "fatigue"
        ],
        "remedy": "Arsenicum Album 30C",
        "description": "Digestive illness commonly causing vomiting, loose motions, stomach pain, and weakness.",
        "advice": "Hydrate aggressively. Seek urgent care if dehydration, blood in stool, or continuous vomiting occurs."
    },
    {
        "condition": "Dry Cough with Chest Discomfort",
        "primary_symptoms": [
            "dry cough",
            "chest pain"
        ],
        "secondary_symptoms": [
            "fever",
            "headache",
            "fatigue",
            "body ache"
        ],
        "remedy": "Bryonia 30C",
        "description": "A condition pattern involving dry cough, pain on movement, and feverish weakness.",
        "advice": "Monitor chest symptoms carefully. Seek medical help for shortness of breath or worsening pain."
    }
]

URGENT_SYMPTOMS = [
    "chest pain",
    "breathing difficulty",
    "shortness of breath",
    "unconsciousness",
    "blood in stool",
    "blood in vomit",
    "severe dehydration"
]

URGENT_MESSAGE = (
    "One or more urgent symptoms were detected. "
    "Please seek immediate medical attention or consult a qualified doctor as soon as possible."
)

DISCLAIMER = (
    "This result is for educational purposes only and is not medical advice. "
    "Please consult a qualified healthcare professional for diagnosis or treatment."
)