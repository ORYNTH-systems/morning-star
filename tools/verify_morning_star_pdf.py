from pathlib import Path
import pypdf

pdf = Path("publication/pdf/MORNING_STAR_REFERENCE_MANUSCRIPT_v1.0.0.pdf")

print("PDF EXISTS:", pdf.exists())
print("PDF BYTES:", pdf.stat().st_size)

reader = pypdf.PdfReader(str(pdf))

print("PAGE COUNT:", len(reader.pages))

text = "\n".join(
    page.extract_text() or ""
    for page in reader.pages
)

terms = [
    "Constitutional Architecture",
    "Governed Knowledge Acquisition",
    "MS-CTE",
    "Literature and Related Work",
    "References",
    "Limitations and Non-Claims"
]

for term in terms:
    if term in text:
        print("[FOUND]", term)
    else:
        print("[MISSING]", term)

print("TEXT LENGTH:", len(text))
