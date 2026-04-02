import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import re

class HomeoRecommender:
    def __init__(self, dataset_path="data/final_cleaned_dataset.csv"):
        self.dataset_path = dataset_path
        self.vectorizer = TfidfVectorizer(stop_words='english', max_features=10000, ngram_range=(1, 2))
        self.df = None
        self.tfidf_matrix = None
        self.is_loaded = False
        self._load_and_train()

    def _load_and_train(self):
        try:
            self.df = pd.read_csv(self.dataset_path)
            # Ensure required columns exist
            if 'remedy' not in self.df.columns or 'symptom_text' not in self.df.columns:
                print("Dataset doesn't have required columns: remedy, symptom_text")
                return
            
            # Clean and prepare symptom text
            self.df['symptom_text'] = self.df['symptom_text'].fillna('')
            
            # Learn TF-IDF on symptom_text
            self.tfidf_matrix = self.vectorizer.fit_transform(self.df['symptom_text'])
            self.is_loaded = True
            print(f"ML Model successfully loaded with {len(self.df)} records.")
        except Exception as e:
            print(f"Failed to load dataset: {e}")
            self.is_loaded = False

    def predict(self, query_text: str, top_k: int = 3):
        if not self.is_loaded:
            return []
            
        # Clean query
        query_text = str(query_text).strip()
        if not query_text:
            return []
            
        # Transform query
        query_vec = self.vectorizer.transform([query_text])
        
        # Calculate similarity
        similarities = cosine_similarity(query_vec, self.tfidf_matrix).flatten()
        
        # Get top indices
        # We fetch more indices to aggregate properly in case same remedy appears multiple times
        top_indices = similarities.argsort()[::-1][:top_k * 10] 
        
        extracted_results = []
        seen_remedies = set()
        
        for idx in top_indices:
            score = similarities[idx]
            if score < 0.05: # Skip very low confidence matches
                continue
                
            remedy = self.df.iloc[idx]['remedy']
            symptom = self.df.iloc[idx]['symptom_text']
            
            if remedy not in seen_remedies:
                seen_remedies.add(remedy)
                # Map it to your standard frontend schema
                extracted_results.append({
                    "condition": "AI Recommended Profile",
                    "remedy": remedy,
                    "confidence": round(float(score), 2), 
                    "score": round(float(score * 100), 1),
                    "matched_symptoms": [symptom],
                    "primary_matched": [],
                    "secondary_matched": [],
                    "reason": f"AI matched your description closely with known symptom: '{symptom}'",
                    "description": f"In Homeopathy, {remedy} is a key remedy identified for conditions involving {symptom}. It is often indicated for patients exhibiting similar constitutional profiles and physical modalities.",
                    "advice": "Please consult a healthcare provider or a homeopath for accurate medical advice."
                })
                
                if len(extracted_results) >= top_k:
                    break
                    
        return extracted_results
