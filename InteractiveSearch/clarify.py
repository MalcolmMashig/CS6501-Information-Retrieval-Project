# clarify.py
import numpy as np    
from sklearn.cluster import MiniBatchKMeans
import json
import os
from collections import Counter


def test():
  with open('InteractiveSearch/data.txt', encoding='utf-8') as f:
    data = json.load(f)
  categories = clarify(data, 5, 'kmeans')
  print('Categories:', categories)

def clarify(results, n_categories=8, type='BoW'):
  if type=='BoW':
    return clarify_BoW(results, n_categories)
  if type=='kmeans':
    return clarify_kmeans(results, n_categories)

def clarify_top_BoW(results, n_categories):
  return []


# 


def clarify_kmeans(results, n_categories):
  titles = results[1]
  captions = results[2]
  doc_count = len(titles)
  word_count = 0
  corpus_bow = Counter()
  vocabulary = set()
  doc_bow_list = []
  
  for i in range(doc_count):
    doc_bow = Counter()
    
    title = tokenize(titles[i])
    caption = tokenize(captions[i])
    
    print('Title:', title)
    print('Caption:', caption)
    
    for word in title:
      doc_bow[word] += 1
      if corpus_bow[word] == 0:
        vocabulary.add(word)
        word_count += 1
      corpus_bow[word] += 1
      
    for word in caption:
      doc_bow[word] += 1
      if corpus_bow[word] == 0:
        vocabulary.add(word)
        word_count += 1
      corpus_bow[word] += 1
    doc_bow_list.append(doc_bow)
  
  
  
  dataset = np.zeros((doc_count, word_count))
  print('Dataset:', dataset)
  w = 0
  for word in corpus_bow:
    d = 0
    corpus_count = corpus_bow[word]
    for doc_bow in doc_bow_list:
      doc_count = doc_bow[word]
      if corpus_count == 0:
        dataset[d][w] = 0
      else:
        dataset[d][w] = doc_count / corpus_count
      d += 1
    w += 1
  
  print('Dataset:', dataset)
  
  model = MiniBatchKMeans(n_clusters=n_categories)
  labels = model.fit_predict(dataset)
  
  cluster_bow_list = [Counter() for _ in range(n_categories)]
  i = 0
  for label in labels:
    cluster_bow_list[label] += doc_bow_list[i]
    i += 1
    
  categories = set()
  for bow in cluster_bow_list:
    top_words = bow.most_common()
    for word, _ in top_words:
      if word not in categories:
        categories.add(word)
        break
  return list(categories)
