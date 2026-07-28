from pathlib import Path
import re
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

SOURCE = Path("publication/manuscript/MORNING_STAR_MANUSCRIPT.md")
OUTPUT = Path("publication/pdf/MORNING_STAR_REFERENCE_MANUSCRIPT_v1.0.0.pdf")

styles = getSampleStyleSheet()

doc = SimpleDocTemplate(
    str(OUTPUT),
    title="Morning Star: A Constitutional Architecture for Governed Knowledge Acquisition in Complex Research Ecosystems",
    author="Ashley S. Harris"
)

story = []

content = SOURCE.read_text(encoding="utf-8").splitlines()

for line in content:
    line = line.strip()

    if not line:
        story.append(Spacer(1, 12))
        continue

    if line.startswith("# "):
        story.append(Paragraph(line[2:], styles["Title"]))
        story.append(Spacer(1, 12))

    elif line.startswith("## "):
        story.append(Paragraph(line[3:], styles["Heading2"]))
        story.append(Spacer(1, 8))

    elif line.startswith("- "):
        story.append(Paragraph("• " + line[2:], styles["BodyText"]))

    else:
        text = re.sub(r"\*\*(.*?)\*\*", r"\1", line)
        story.append(Paragraph(text, styles["BodyText"]))

doc.build(story)

print("PDF_GENERATION_COMPLETE")
print(f"OUTPUT:{OUTPUT}")
print(f"BYTES:{OUTPUT.stat().st_size}")
