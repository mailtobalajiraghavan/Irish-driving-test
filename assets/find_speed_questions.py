import json

with open('questions.json', encoding='utf-8') as f:
    data = json.load(f)

results = []
for q in data:
    text = q['text'].lower()
    if 'speed limit' in text or 'km/h' in text or ('speed' in text and 'limit' in text):
        results.append(q)

print(f"Found {len(results)} speed limit related questions:\n")

for r in results:
    print(f"ID {r['id']}: {r['text']}")
    for i, opt in enumerate(r['options']):
        marker = " [CORRECT]" if i == r['correctIndex'] else ""
        print(f"  {i+1}. {opt}{marker}")
    print()
