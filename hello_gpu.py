import spacy
from copy import copy
from spacy_transformers.pipeline_component import DEFAULT_CONFIG
from thinc.api import Config, set_gpu_allocator, require_gpu

if spacy.prefer_gpu():
    print("\n\033[92m" + "✔ Using GPU" + "\033[0m\n")
    set_gpu_allocator("pytorch")
    require_gpu(0)
else:
    print("\n\033[91m" + "✘ NOT Using GPU!" + "\033[0m\n")

config = copy(DEFAULT_CONFIG["transformer"])
config["model"]["name"] = "model/distilbert-base-nli-stsb-mean-tokens"

nlp = spacy.blank("en")
transformer = nlp.add_pipe("transformer", config=config)
transformer.model.initialize()

doc = nlp("hello world")

tokvecs = doc._.trf_data.tensors[-1]
print(tokvecs)
