# bag_of_word.py

def get_count(word, BoW):
    if word in BoW:
        return BoW[word]
    else:
        return 0;

def bag_of_word(query, documents):
    query_words = tokenize(query)
    words = []
    for document in documents:
        doc_words = tokenize(document, query_words)
        words += doc_words
    BoW = {}
    for word in words:
        BoW[word] = get_count(word, BoW) + 1
    return BoW
