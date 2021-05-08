# clarify.py

def clarify(BoW, n_categories = 8):
  return list(dict(sorted(BoW.items(), key=lambda item: -item[1])).keys())[0:(n_categories - 1)]
