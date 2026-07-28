from pathlib import Path
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    PageBreak
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.pagesizes import letter
from reportlab.lib.enums import TA_CENTER
from reportlab.pdfbase.pdfmetrics import stringWidth
import re
from datetime import datetime

SOURCE = Path("publication/manuscript/MORNING_STAR_MANUSCRIPT.md")
OUTPUT = Path("publication/pdf/MORNING_STAR_REFERENCE_MANUSCRIPT_v1.0.0.pdf")

styles = getSampleStyleSheet()

title_style = ParagraphStyle(
    "TitleCustom",
    parent=styles["Title"],
    alignment=TA_CENTER,
    spaceAfter=24
)

author_style = ParagraphStyle(
    "AuthorCustom",
    parent=styles["Normal"],
    alignment=TA_CENTER,
    spaceAfter=12
)

heading_style = ParagraphStyle(
    "HeadingCustom",
    parent=styles["Heading2"],
    spaceBefore=18,
    spaceAfter=10
)

body_style = ParagraphStyle(
    "BodyCustom",
    parent=styles["BodyText"],
    leading=14,
    spaceAfter=8
)

doc = SimpleDocTemplate(
    str(OUTPUT),
    pagesize=letter,
    title="Morning Star: A Constitutional Architecture for Governed Knowledge Acquisition in Complex Research Ecosystems",
    author="Ashley S. Harris"
)

story = []

lines = SOURCE.read_text(encoding="utf-8").splitlines()

for index, line in enumerate(lines):

    line = line.strip()

    if not line:
        story.append(Spacer(1, 10))
        continue

    if index == 0 and line.startswith("# "):
        story.append(Paragraph(line[2:], title_style))
        story.append(Spacer(1, 24))
        story.append(Paragraph("Ashley S. Harris", author_style))
        story.append(Paragraph("Version 1.0.0 Reference Manuscript", author_style))
        story.append(Paragraph(datetime.utcnow().strftime("%Y-%m-%d"), author_style))
        story.append(PageBreak())
        continue

    if line.startswith("# "):
        story.append(Paragraph(line[2:], heading_style))
        continue

    if line.startswith("## "):
        story.append(Paragraph(line[3:], heading_style))
        continue

    if line.startswith("- "):
        story.append(
            Paragraph("• " + line[2:], body_style)
        )
        continue

    text = re.sub(r"\*\*(.*?)\*\*", r"\1", line)
    text = text.replace("\\[", "").replace("\\]", "")

    story.append(
        Paragraph(text, body_style)
    )

doc.build(story)

print("FINAL_PDF_GENERATION_COMPLETE")
print(f"OUTPUT: {OUTPUT}")
print(f"BYTES: {OUTPUT.stat().st_size}")
