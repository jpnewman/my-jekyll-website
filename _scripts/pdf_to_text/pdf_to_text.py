import os

from pypdf import PdfReader

SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))

pdf_file=os.path.join(SCRIPT_PATH, "../../johnpaul_newman_cv.pdf")

reader = PdfReader(pdf_file)

for page in reader.pages:
    print(page.extract_text())
