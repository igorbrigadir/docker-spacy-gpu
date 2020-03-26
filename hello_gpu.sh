#!/bin/bash
python hello_gpu.py
python -m timeit -s 'import spacy; spacy.require_gpu(); model = spacy.load("/model/en_trf_distilbertbaseuncased_lg-2.2.0"); text = "The quick brown fox jumps over the lazy dog.";'  'model(text).vector'
sleep 1
python -m timeit -s 'import spacy; spacy.require_gpu(); model = spacy.load("/model/en_trf_distilbertbaseuncased_lg-2.2.0"); text = "Jackdaws love my big sphinx of quartz.";'  'model(text).vector'
