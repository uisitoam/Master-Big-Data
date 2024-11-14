import praw as praw
import datetime as dt
import json
import re
from sklearn.feature_extraction.text import TfidfVectorizer
import pandas as pd
from collections import Counter
from keybert import KeyBERT
from wordcloud import WordCloud
import matplotlib.pyplot as plt


# autenticacion en reddit
reddit = praw.Reddit(
    client_id='v_kyY1nFQek3Nat6Teq5MQ',
    client_secret='3t-rYIFAuuz5djkQ6AMx7djRB2Rl9g',
    user_agent='reddit_app_tgine by /u/luisam222'
)

# subreddits a analizar
subreddit_books = reddit.subreddit('books')
subreddit_op = reddit.subreddit('OnePieceSpoilers')





# recuperamos el corpus de un subreddit
def corpusRetrieval(subreddit, limite, filename, limite_anidado=0):
    """
    Recupera el corpus de un subreddit y lo guarda en un archivo JSON.

    Parameters
    ----------
    subreddit : objeto subreddit
        Objeto subreddit de donde se recuperarán los posts.
    limite : int
        Número de posts a recuperar.
    filename : str
        Nombre del archivo donde se guardará el corpus.
    limite_anidado : int, optional
        Número de comentarios anidados a recuperar. El valor por defecto es 0.

    Returns
    -------
    list
        Lista de posts con sus comentarios.
    
    Raises
    ------
    AssertionError
        Si los argumentos no son del tipo esperado.
    """

    # validamos los parámetros de entrada
    assert hasattr(subreddit, 'top'), "'subreddit' debe ser un objeto subreddit"
    assert isinstance(limite, int) and limite > 0, "'limite' debe ser un entero positivo"
    assert isinstance(filename, str) and filename, "'nombre_archivo' debe ser una cadena de texto no vacía"
    assert isinstance(limite_anidado, int) and limite_anidado >= 0 or limite_anidado is None, "'limite_anidado' debe ser un entero no negativo o None"

    corpus = []

    # posts del top all time
    for sub in subreddit.top(limit=limite):  
        # información del post
        post = {
            'titulo': sub.title,
            'texto': sub.selftext if sub.selftext else '',
            'puntuacion': sub.score,
            'id': sub.id,
            'num_comentarios': sub.num_comments,
            'creado': dt.datetime.fromtimestamp(sub.created_utc).isoformat(sep=' '), # formato iso
            'autor': sub.author.name if sub.author else 'N/A',
            'subreddit': sub.subreddit.display_name,
            'ratio_votos_positivos': sub.upvote_ratio,
        }

        sub.comments.replace_more(limit=limite_anidado)  # comentarios anidados a recuperar, por defecto 0
        comentarios = sub.comments.list() # recuperamos la lista de comentarios
        
        # información de los comentarios de la publicación
        comentarios_post = [{'id': comentario.id, 
                             'cuerpo': comentario.body, 
                             'puntuacion': comentario.score, 
                             'autor': comentario.author.name if comentario.author else 'N/A', 
                             'creado': dt.datetime.fromtimestamp(comentario.created_utc).isoformat(sep=' '), # formato iso
                             'id_padre': comentario.parent_id} 
                            for comentario in comentarios]

        post['comentarios'] = comentarios_post # añadimos los comentarios a la información del post

        corpus.append(post)

    # guardamos en un archivo json
    with open(f'{filename}.json', 'w', encoding='utf-8') as f:
        json.dump(corpus, f, ensure_ascii=False, indent=4)

    print(f"Corpus guardado en '{filename}.json'")

    return corpus


# recuperamos los corpus de cada subreddit 
corB = corpusRetrieval(subreddit_books, 500, 'corpus_books')
corOP = corpusRetrieval(subreddit_op, 500, 'corpus_op')





# limpiamos el corpus
def cleanCorpus(file):
    """
    Limpia el corpus eliminando URLs y concatenando títulos y textos de posts y comentarios.

    Parameters
    ----------
    file : list o str
        Lista de posts o ruta a un archivo JSON que contiene los posts.

    Returns
    -------
    list
        Lista de documentos procesados.
    
    Raises
    ------
    AssertionError
        Si los argumentos no son del tipo esperado.
    """

    # validamos los parámetros de entrada
    assert isinstance(file, (list, str)), "'archivo' debe ser una lista o la ruta de un archivo json"

    # si ya tenemos la lista
    if isinstance(file, list): 
        corpus = file

    # cargamos el archivo json
    elif isinstance(file, str):
        assert file.endswith('.json'), "'archivo' debe terminar en .json"

        with open(file, 'r', encoding='utf-8') as f: 
            corpus = json.load(f)
    
    # eliminamos URLs de un texto
    def eliminar_urls(texto):
        return re.sub(r'http\S+|www\S+|https\S+', '', texto, flags=re.MULTILINE)

    # concatenamos los textos y títulos de los posts, y cogemos texto de comentarios
    documentos = []
    for post in corpus:
        # procesamos el título y el texto del post como un documento individual
        titulo = eliminar_urls(post['titulo']) # quitamos urls
        texto = eliminar_urls(post['texto']) # quitamos urls
        texto_completo = titulo + ' ' + texto # concatenamos
        documentos.append(texto_completo)
        
        # procesamos cada comentario como un documento individual
        for comentario in post['comentarios']:
            texto_comentario = eliminar_urls(comentario['cuerpo']) # quitamos urls
            documentos.append(texto_comentario)

    # calculamos la longitud total del corpus (número de post+comentarios y número de términos)
    print(f'Número de posts+comentarios en el corpus: {len(documentos):,}')
    longitud = sum(len(doc) for doc in documentos)
    print(f'Número de términos en el corpus: {longitud:,}') # le damos formato de miles con ,
    return documentos


documents_books = cleanCorpus('corpus_books.json')
documents_op = cleanCorpus('corpus_op.json')




# extraemos las palabras clave
def getKeyWords(data, num_terminos, nn=False):
    """
    Extrae palabras clave de los documentos usando TF-IDF o KeyBERT.

    Parameters
    ----------
    data : list
        Lista de cadenas de texto.
    num_terminos : int
        Número de términos más comunes a devolver.
    nn : bool, optional
        Si es True, usa KeyBERT para extraer palabras clave. Si es False, usa TF-IDF. El valor por defecto es False.

    Returns
    -------
    list
        Lista de tuplas con las palabras clave y su frecuencia o score.
    Counter
        Contador de la frecuencia de las palabras clave.

    Raises
    ------
    AssertionError
        Si los parámetros no cumplen con los tipos esperados.
    """

    # verificamos parámetros de entrada
    assert isinstance(data, list) and all(isinstance(doc, str) for doc in data), "'datos' debe ser una lista de cadenas de texto."
    assert isinstance(num_terminos, int) and num_terminos > 0, "'num_terminos' debe ser un entero positivo."
    assert isinstance(nn, bool), "'usar_nn' debe ser un valor booleano."

    if nn:
        modelo = KeyBERT()

        # extraemon palabras clave de cada documento
        todas_palabras_clave = []
        for doc in data:
            palabras_clave = modelo.extract_keywords(doc, stop_words='english', top_n=50)
            todas_palabras_clave.extend([palabra[0] for palabra in palabras_clave])

        # contamos la frecuencia de las palabras clave
        frecuencia_palabras_clave = Counter(todas_palabras_clave)

        # mostramos las 'num_terminos' palabras clave más comunes
        palabras_clave_comunes = frecuencia_palabras_clave.most_common(num_terminos)

        return palabras_clave_comunes, frecuencia_palabras_clave

    else:
        # vectorizamos el texto usando TfidfVectorizer
        vectorizador = TfidfVectorizer(stop_words='english', min_df=10)
        matriz_tfidf = vectorizador.fit_transform(data)  # dim(numero posts+comentarios, numero palabras)

        suma_tfidf = matriz_tfidf.sum(axis=0)  # dim(1, numero palabras)
        puntuacion_tfidf = [(termino, suma_tfidf[0, idx]) for termino, idx in vectorizador.vocabulary_.items()]  # (palabra, score)
        puntuacion_tfidf.sort(key=lambda x: x[1], reverse=True)  # Ordenar por score

        # contamos la frecuencia de los términos
        frecuencia_terminos = Counter()
        for doc in data:
            frecuencia_terminos.update(doc.split())

        terminos_mas_frecuentes = frecuencia_terminos.most_common(num_terminos)

        return puntuacion_tfidf, terminos_mas_frecuentes


tfidf_books_scores, freq_books = getKeyWords(documents_books, 100)
tfidf_op_scores, freq_op = getKeyWords(documents_op, 100)

keybert_books, keybert_freq_books = getKeyWords(documents_books, 100, nn=True)
keybert_op, keybert_freq_op = getKeyWords(documents_op, 100, nn=True)





# visualización de resultados
def tableView(data, colsname, num_rows):
    """
    Muestra un DataFrame en forma de tabla con múltiples columnas.

    Parameters
    ----------
    data : list
        Lista de datos.
    colsname : list
        Lista de nombres de columnas.
    num_rows : int
        Número de filas por columna.

    Returns
    -------
    DataFrame
        DataFrame con los datos organizados en columnas.

    Raises
    ------
    AssertionError
        Si los argumentos no son del tipo esperado.
    """

    # validamos los parámetros de entrada
    assert isinstance(data, list), "'data' debe ser una lista"
    assert isinstance(colsname, list), "'colsname' debe ser una lista"
    assert isinstance(num_rows, int) and num_rows > 0, "'num_rows' debe ser un entero positivo"
    
    df = pd.DataFrame(data, columns=colsname)

    # dividimos el DataFrame en partes de num_rows filas cada una
    partes_df = [df.iloc[i:i + num_rows].reset_index(drop=True) for i in range(0, len(df), num_rows)]

    # añadimos una columna de índices en cada parte
    for idx, parte in enumerate(partes_df):
        parte.insert(0, '', range(idx * num_rows + 1, idx * num_rows + len(parte) + 1))

    # concatenamos las partes en un solo DataFrame con múltiples columnas
    resultado = pd.concat(partes_df, axis=1)
    return resultado.style.hide(axis='index')


tableView(tfidf_books_scores[:50], ['Término', 'Puntuación TF-IDF'], 10)
tableView(tfidf_op_scores[:50], ['Término', 'Puntuación TF-IDF'], 10)
tableView(freq_books, ['Término', 'Frecuencia'], 20)
tableView(freq_op, ['Término', 'Frecuencia'], 20)
tableView(keybert_books[:50], ['Término', 'Frecuencia'], 10)
tableView(keybert_op[:50], ['Término', 'Frecuencia'], 10)





# nube de palabras
def nubePalabras(data):
    """
    Genera una nube de palabras a partir de un diccionario de términos y su frecuencia.
    
    """
    
    wordcloud = WordCloud(width=1900, height=1000, background_color='black').generate_from_frequencies(data)

    plt.figure(figsize=(20, 10))
    plt.imshow(wordcloud)
    plt.axis('off')
    plt.show()

# tfidf
nubePalabras(dict(tfidf_books_scores))
nubePalabras(dict(tfidf_op_scores))
# mas frecuentes
nubePalabras(dict(freq_books))
nubePalabras(dict(freq_op))
# keybert
nubePalabras(keybert_freq_books)
nubePalabras(keybert_freq_op)