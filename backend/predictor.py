from typing import List, Dict, Any
from conditions import URGENT_SYMPTOMS

PRIMARY_WEIGHT = 2
SECONDARY_WEIGHT = 1
MINIMUM_SCORE_THRESHOLD = 2


def detect_urgent_symptoms(normalized_symptoms: List[str]) -> List[str]:
    return [symptom for symptom in normalized_symptoms if symptom in URGENT_SYMPTOMS]


def calculate_weighted_match(
    input_symptoms: List[str],
    primary_symptoms: List[str],
    secondary_symptoms: List[str]
) -> Dict[str, Any]:
    primary_matched = [symptom for symptom in input_symptoms if symptom in primary_symptoms]
    secondary_matched = [symptom for symptom in input_symptoms if symptom in secondary_symptoms]

    primary_score = len(primary_matched) * PRIMARY_WEIGHT
    secondary_score = len(secondary_matched) * SECONDARY_WEIGHT
    total_score = primary_score + secondary_score

    max_possible_score = (len(primary_symptoms) * PRIMARY_WEIGHT) + (len(secondary_symptoms) * SECONDARY_WEIGHT)
    confidence = round(total_score / max_possible_score, 2) if max_possible_score > 0 else 0.0

    return {
        "primary_matched": primary_matched,
        "secondary_matched": secondary_matched,
        "matched": primary_matched + secondary_matched,
        "primary_score": primary_score,
        "secondary_score": secondary_score,
        "total_score": total_score,
        "confidence": confidence
    }


def build_reason(condition_name: str, primary_matched: List[str], secondary_matched: List[str]) -> str:
    parts = []

    if primary_matched:
        parts.append(f"primary symptom match: {', '.join(primary_matched)}")
    if secondary_matched:
        parts.append(f"secondary symptom match: {', '.join(secondary_matched)}")

    if not parts:
        return f"No strong symptom match found for {condition_name}."

    return f"{condition_name} matched because of " + " | ".join(parts) + "."