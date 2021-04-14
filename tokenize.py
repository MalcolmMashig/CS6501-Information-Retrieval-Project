# tokenize.py
                                         
import nltk
import re

def tokenize(text, query_words = []):
    tokens = nltk.word_tokenize(text)
    words = []
    for token in tokens:
        token = token.lower()
        token = re.sub("[^a-z]", "", token)
        if (len(token) > 0) and (token not in stopwords.words('english')) and (token not in query_words):
            words.append(token)
    return words
    
