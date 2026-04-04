import pandas as pd
import os

csv_path = 'SmartHomeoAIAdvisor_Dataset_V2.csv'
df = pd.read_csv(csv_path)

new_rows = [
    {
        'symptom': 'cold',
        'possible_condition': 'Common Cold / Coryza',
        'severity': 'low',
        'patient_age_group': 'all',
        'remedy_name': 'Allium Cepa',
        'potency': '30C',
        'keynote_indication': 'Profuse watery burning nasal discharge like cutting an onion; bland eye discharge; worse in warm room; better outdoors',
        'remedy_reason': 'At LOW severity Allium Cepa 30C is first choice for the classic burning runny nose better in fresh air. Stops early cold signs',
        'suitable_for_bp_high': 'yes - safe for BP patients',
        'suitable_for_diabetic': 'yes - safe for diabetics',
        'avoid_if_allergy': 'Onion allergy (dilution safe)',
        'dietary_restrictions': 'Avoid allergens; warm water steam inhalation; vitamin C rich foods',
        'what_to_avoid': 'Coffee / Camphor / Mint / Warm rooms / Pollen / Dust',
        'consult_doctor': 'no',
        'source_book': "Allen's Keynotes + Boericke",
        'additional_notes': 'The anti-onion remedy; burning nose with bland eyes is keynote'
    },
    {
        'symptom': 'cold',
        'possible_condition': 'Flu-like Cold with Heaviness',
        'severity': 'moderate',
        'patient_age_group': 'all',
        'remedy_name': 'Gelsemium',
        'potency': '30C',
        'keynote_indication': 'Cold with great heaviness of head and limbs; dullness; weak limbs; worse from sudden motion; no thirst',
        'remedy_reason': 'At MODERATE severity when cold comes with weakness and heaviness Gelsemium 30C addresses the neurological component of flu-like colds',
        'suitable_for_bp_high': 'yes - safe; actually reduces anxiety-driven BP',
        'suitable_for_diabetic': 'yes - safe for diabetics',
        'avoid_if_allergy': 'None',
        'dietary_restrictions': 'Complete rest; light food; avoid sudden movements',
        'what_to_avoid': 'Coffee / Camphor / Mint / Sudden movement / Excitement / Heat',
        'consult_doctor': 'no',
        'source_book': "Allen's Keynotes + Boericke",
        'additional_notes': 'Heaviness of head and limbs with drowsiness is keynote'
    },
    {
        'symptom': 'cold',
        'possible_condition': 'Severe Cold with Prostration',
        'severity': 'high',
        'patient_age_group': 'all',
        'remedy_name': 'Arsenicum Album',
        'potency': '200C',
        'keynote_indication': 'Cold with intense restlessness and anxiety; thirst for small sips; burning heat; worse after midnight; chilly despite fever',
        'remedy_reason': 'At HIGH severity when cold causes intense weakness and anxiety Arsenicum Album 200C is required. Addresses profound debility',
        'suitable_for_bp_high': 'yes - safe and calms anxiety',
        'suitable_for_diabetic': 'yes - safe for diabetics',
        'avoid_if_allergy': 'Arsenic (dilution safe)',
        'dietary_restrictions': 'Warm drinks only; avoid cold food; light diet',
        'what_to_avoid': 'Coffee / Camphor / Mint / Cold / Midnight',
        'consult_doctor': 'yes - seek medical eval if heart rate high',
        'source_book': "Allen's Keynotes + Boericke",
        'additional_notes': 'Particularly useful for severe winter colds with weakness'
    }
]

df_new = pd.DataFrame(new_rows)
df_final = pd.concat([df, df_new], ignore_index=True)
df_final.to_csv(csv_path, index=False)
print("Finished adding cold rows.")
