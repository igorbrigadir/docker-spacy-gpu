import spacy

spacy.load("/model/en_trf_distilbertbaseuncased_lg-2.2.0")

if spacy.prefer_gpu():
    print("\n\033[92m" + "✔ Using GPU" + "\033[0m\n")
else:
    print("\n\033[91m" + "✘ NOT Using GPU!" + "\033[0m\n")
