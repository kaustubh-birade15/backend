import os

replacements = {
    "0xFFFDFBF7": "0xFFF4F2FA",
    "0xFF82CAAE": "0xFF8B78E6",
    "0xFFA8E6CF": "0xFFD6C8FF",
    "0xFFE8F8F5": "0xFFF3EFFF",
    "0xFFFFD3B6": "0xFFFFB3B3",
    "0xFFD5DBF6": "0xFFA1D9E7",
    "0xFFFBE0C3": "0xFFFFD1A9",
    "0xFF2C3E50": "0xFF3B3B58",
    "0xFF34495E": "0xFF4C4C6D",
    "0xFF7F8C8D": "0xFF8B8B9E",
    "0xFF95A5A6": "0xFF8B8B9E",
    "0xFFBDC3C7": "0xFFA6A6C1",
    "0xFFEAEDED": "0xFFE8E5F0",
    "0xFF427A9B": "0xFF8B78E6",
    "0xBB427A9B": "0xBB8B78E6",
    "0xFF1E293B": "0xFF3B3B58",
    "0xFF64748B": "0xFF8B8B9E",
    "0xFF334155": "0xFF4C4C6D",
    "0xFFE2E8F0": "0xFFE8E5F0",
    "0xFF94A3B8": "0xFFA6A6C1",
    "0xFFFFE8D6": "0xFFFFF0F5",
    "0xFFD35400": "0xFFC44D7C",
    "0xFFA04000": "0xFF9B3A60",
    "0xFFFDEDEC": "0xFFFFF0F5",
    "0xFFF5B7B1": "0xFFFFB3B3",
    "0xFFE74C3C": "0xFFEF5350",
    "0xFFC0392B": "0xFFD32F2F",
    "0xFFF0E68C": "0xFFFFD1A9",
    "0xFF87CEFA": "0xFFA1D9E7",
    "0xFFE6E6FA": "0xFFD6C8FF",
    "0xFFF0F9F5": "0xFFF3EFFF" # Profile screen non-destructive action tile
}

def replace_colors(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                changed = False
                for old, new in replacements.items():
                    if old in content:
                        content = content.replace(old, new)
                        changed = True
                
                if changed:
                    with open(file_path, "w", encoding="utf-8") as f:
                        f.write(content)
                    print(f"Updated colors in {file_path}")

if __name__ == "__main__":
    replace_colors(r"C:\Users\kaust\Mediguide_Project\mediguide_app\lib")
    print("Done replacing.")
