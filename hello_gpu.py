import spacy
from thinc.api import Config, set_gpu_allocator, require_gpu

if spacy.prefer_gpu():
    print("\n\033[92m" + "✔ Using GPU" + "\033[0m\n")
    set_gpu_allocator("pytorch")
    require_gpu(0)
else:
    print("\n\033[91m" + "✘ NOT Using GPU!" + "\033[0m\n")

distilbert = """
[transformer]
max_batch_items = 4096

[transformer.model]
@architectures = "spacy-transformers.TransformerModel.v1"
name = "model/distilbert-base-nli-stsb-mean-tokens"
tokenizer_config = {"use_fast": true}

[transformer.model.get_spans]
@span_getters = "spacy-transformers.strided_spans.v1"
window = 128
stride = 96
"""

CONFIG = Config().from_str(distilbert)

nlp = spacy.blank("en")

transformer = nlp.add_pipe("transformer", config=CONFIG["transformer"])
transformer.model.initialize()

doc = nlp("hello world")

tokvecs = doc._.trf_data.tensors[-1]
print(tokvecs)
