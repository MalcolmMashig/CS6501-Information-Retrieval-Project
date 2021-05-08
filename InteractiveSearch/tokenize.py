# tokenize.py
                                         
#import nltk
#import re

# def tokenize(results, query_words = []):
#   tokens = nltk.word_tokenize(text)
#    words = []
#    for token in tokens:
#        token = token.lower()
#        token = re.sub("[^a-z]", "", token)
#        if (len(token) > 0) and (token not in stopwords.words('english')) and (token not in query_words):
#            words.append(token)
#    return words

from nltk.tokenize import word_tokenize
    
def tokenize(text, query = False):
    if query:
        return word_tokenize(text)
    else:
        tokenized_titles = [word_tokenize(i) for i in text[1]]
        tokenized_captions = [word_tokenize(i) for i in text[2]]
        return tokenized_titles, tokenized_captions