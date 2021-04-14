# issue_query.py

import urllib
import requests
from fake_useragent import UserAgent
from bs4 import BeautifulSoup
import re
import nltk
nltk.download('words')
nltk.download('stopwords')
from nltk.corpus import stopwords

def issue_query(query, n_results = 100, scrape_websites = False):
  ua = UserAgent(verify_ssl=False)
  google_url = "https://www.google.com/search?q=" + urllib.parse.quote_plus(query) + "&num=" + str(n_results)
  response = requests.get(google_url, {"User-Agent": ua.random})
  soup = BeautifulSoup(response.text, "html.parser")
  result_div = soup.find_all('div', attrs = {'class': 'ZINbbc'})
  links = []
  titles = []
  descriptions = []
  for r in result_div:
      try:
          link = r.find('a', href = True)
          title = r.find('div', attrs={'class':'vvjwJb'}).get_text()
          description = r.find('div', attrs={'class':'s3v9rd'}).get_text()
          if link != '' and title != '' and description != '': 
              links.append(link['href'])
              titles.append(title)
              descriptions.append(description)
      except:
          continue
  to_remove = []
  clean_links = []
  for i, l in enumerate(links):
      clean = re.search('\/url\?q\=(.*)\&sa',l)
      if clean is None:
          to_remove.append(i)
          continue
      clean_links.append(clean.group(1))
  for x in to_remove:
      del titles[x]
      del descriptions[x]
  if scrape_websites:
    web_texts = []
    words = set(nltk.corpus.words.words())
    stop_words = stopwords.words('english')
    for url in clean_links:
        r = requests.get(url)
        html = r.text
        soup = BeautifulSoup(html, "html5lib")
        text = soup.get_text()
        text = text.replace('\n', ' ')
        new_text = " ".join(w for w in nltk.wordpunct_tokenize(text)
                            if (w.lower() in words)
                            and (w.lower() not in stop_words)
                            and (len(w.lower()) > 1))
        web_texts.append(new_text)
    return clean_links, titles, descriptions, web_texts
  return clean_links, titles, descriptions
