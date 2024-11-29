import subprocess
import sys
import pkg_resources
from packaging import version


def check_and_install_packages():
    required_packages = {
        'torch': 'torch',
        'pandas': 'pandas',
        'transformers': 'transformers',
        'accelerate': 'accelerate>=0.26.0',  # Agregado con versión mínima
        'numpy': 'numpy',
        'spacy': 'spacy',
        'scikit-learn': 'scikit-learn',
        'sentencepiece': 'sentencepiece',
        'xgboost': 'xgboost',
        'imblearn': 'imblearn',
        'matplotlib': 'matplotlib',
        'seaborn': 'seaborn',
        'datasets': 'datasets',
        'tqdm': 'tqdm',
        'joblib': 'joblib'
    }
    
    missing_packages = []
    upgrade_packages = []
    
    # Verificar paquetes instalados y sus versiones
    installed_packages = {pkg.key: pkg.version for pkg in pkg_resources.working_set}
    
    for package, pip_name in required_packages.items():
        if '>' in pip_name or '<' in pip_name or '=' in pip_name:
            # Manejar requisitos de versión
            pkg_name, pkg_version = pip_name.split('>=') if '>=' in pip_name else (pip_name, None)
            pkg_key = package.lower()
            if pkg_key in installed_packages:
                if pkg_version and version.parse(installed_packages[pkg_key]) < version.parse(pkg_version):
                    upgrade_packages.append(pip_name)
            else:
                missing_packages.append(pip_name)
        else:
            # Paquetes sin requisitos de versión específicos
            if package.lower() not in installed_packages:
                missing_packages.append(pip_name)
    
    # Instalar paquetes faltantes
    if missing_packages:
        print("Instalando paquetes necesarios...")
        for package in missing_packages:
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', package])
        print("Instalación completada.")
    else:
        print("Todos los paquetes necesarios ya están instalados.")
    
    # Actualizar paquetes que no cumplen con la versión requerida
    if upgrade_packages:
        print("Actualizando paquetes a las versiones requeridas...")
        for package in upgrade_packages:
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', package])
        print("Actualización completada.")
    else:
        print("Todas las versiones de los paquetes están actualizadas.")
    
    # Verificar si el modelo 'en_core_web_sm' está instalado
    try:
        import spacy
        spacy.load('en_core_web_sm')
        print("El modelo 'en_core_web_sm' de spaCy ya está instalado.")
    except OSError:
        print("Descargando el modelo 'en_core_web_sm' de spaCy...")
        subprocess.check_call([sys.executable, '-m', 'spacy', 'download', 'en_core_web_sm'])
        print("Modelo 'en_core_web_sm' descargado e instalado correctamente.")

check_and_install_packages()


import pandas as pd 
import numpy as np
from tqdm import tqdm
import ast
import xml.etree.ElementTree as ET
import spacy
import re
import string
import joblib
import os
import matplotlib.pyplot as plt
import seaborn as sns
import itertools
import torch
import torch.nn as nn
from transformers import AutoModelForCausalLM, BertModel, GPT2LMHeadModel, AutoTokenizer, BertTokenizer, T5Tokenizer, T5ForConditionalGeneration
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier





ruta_entrenamiento = '/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/ficheros necesarios/training_data.csv'
df = pd.read_csv(ruta_entrenamiento, sep=' ')

def get_topics_from_xml(data, xml_file):
    # parseado del archivo XML
    tree = ET.parse(xml_file)
    root = tree.getroot()

    # Crear un diccionario para mapear número a descripción
    number_to_description = {}
    for topic in root.findall('topic'):
        number = topic.find('number').text.strip()
        description = topic.find('description').text.strip()
        number_to_description[number] = description

    # creamos un diccionario con un 'mapa' de número de topico a descripción
    number_to_description = {int(k): v for k, v in number_to_description.items()}
    data.insert(1, 'topic_text', data['topic'].map(number_to_description))
    return data

xml_file = '/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/ficheros necesarios/misinfo-2020-topics-filtered.xml'

df = get_topics_from_xml(df, xml_file)



# Cargar el modelo de spaCy
nlp = spacy.load('en_core_web_sm')

# Función para limpiar el texto
def clean_text(text):
    # Eliminar HTML y URLs
    text = re.sub(r'http\S+|www\S+|https\S+', '', text, flags=re.MULTILINE)
    text = re.sub(r'<.*?>', '', text)
    # Eliminar hashtags
    text = re.sub(r'#\w+', '', text)
    # Eliminar caracteres no latinos
    text = re.sub(r'[^a-zA-Z\s]', '', text)
    
    # Eliminar caracteres especiales y puntuación
    text = text.translate(str.maketrans('', '', string.punctuation))
    
    # Convertir a minúsculas
    text = text.lower()

    # Reemplazar múltiples espacios por un solo espacio
    text = re.sub(r'\s+', ' ', text).strip()
    
    # Procesar el texto con spaCy
    doc = nlp(text)
    
    # Eliminar stop words y lematizar
    tokens = [token.lemma_ for token in doc if not token.is_stop]
    
    return ' '.join(tokens)

# Ejemplo de texto
df['cleaned_passage'] = df['passage'].apply(clean_text)

# Mostrar los primeros elementos de la columna limpiada
df.to_csv('df.csv', index=False)




class Attention(nn.Module):
    def __init__(self, embed_dim):
        super(Attention, self).__init__()
        self.attention = nn.Linear(embed_dim, 1)

    def forward(self, embeddings):
        weights = torch.softmax(self.attention(embeddings), dim=0)
        weighted_sum = torch.sum(weights * embeddings, dim=0)
        return weighted_sum
    
def combine_embeddings_attention(embeddings, attention_layer):
    embeddings_tensor = torch.tensor(embeddings)
    return attention_layer(embeddings_tensor).detach().numpy()

# tamaño del embedding para BioMedLM
biomed_model = AutoModelForCausalLM.from_pretrained("stanford-crfm/BioMedLM")
embed_dim_biomed = biomed_model.config.hidden_size
print(f"El tamaño del embedding para BioMedLM es {embed_dim_biomed}")

# tamaño del embedding para ClinicalBERT
bert_model = BertModel.from_pretrained('emilyalsentzer/Bio_ClinicalBERT', num_labels=2)
embed_dim_bert = bert_model.config.hidden_size
print(f"El tamaño del embedding para ClinicalBERT es {embed_dim_bert}")


attention_layer_biomed = Attention(embed_dim=embed_dim_biomed)
attention_layer_bert = Attention(embed_dim=embed_dim_bert)


device = torch.device('cpu')

# dividir el texto en fragmentos de 512 tokens
def split_into_chunks(text, tokenizer, max_length=512):
    tokens = tokenizer.tokenize(text)
    chunks = [tokens[i:i + max_length] for i in range(0, len(tokens), max_length)]
    return chunks

# procesar cada fragmento y combinar los resultados
def process_text(text, tokenizer, model, attention_layer):
    assert isinstance(text, str), "'text' debe ser una cadena de texto" 
    assert hasattr(tokenizer, 'convert_tokens_to_ids'), "'tokenizer' debe ser un tokenizador de Hugging Face"
    assert isinstance(attention_layer, Attention), "'attention_layer' debe ser una capa de atención de la clase Attention"
    
    chunks = split_into_chunks(text, tokenizer)
    embeddings = []

    for chunk in chunks:
        tokens = tokenizer.convert_tokens_to_ids(chunk)
        tokens_tensor = torch.tensor([tokens]).to(device)
        
        # extraer la representación del [CLS] token (primer token, captura la represetnacion semantica de la secuencia)
        with torch.no_grad():
            if isinstance(model, GPT2LMHeadModel):
                outputs = model(tokens_tensor, output_hidden_states=True)
                cls_embedding = outputs.hidden_states[-1][:, 0, :].cpu().numpy()

            elif isinstance(model, BertModel):
                outputs = model(tokens_tensor)
                cls_embedding = outputs.last_hidden_state[:, 0, :].cpu().numpy()
            
            else: 
                raise ValueError("Modelo no soportado")
        
        cls_embedding = np.squeeze(cls_embedding)
        embeddings.append(cls_embedding)
    
    # convertir la lista de arrays de NumPy a un solo array de NumPy
    embeddings_array = np.array(embeddings)

    # combinar las representaciones
    combined_embedding = combine_embeddings_attention(embeddings_array, attention_layer)
    
    return combined_embedding



tqdm.pandas()

# cargamos el tokenizador de BioMedLM y Bio_ClinicalBERT
biomed_tokenizer = AutoTokenizer.from_pretrained("stanford-crfm/BioMedLM")
bert_tokenizer = BertTokenizer.from_pretrained('emilyalsentzer/Bio_ClinicalBERT')

def exec_process(data, modelos=[(biomed_model, 'biomed'), (bert_model, 'bioclinicalbert')], tokenizadores=[biomed_tokenizer, bert_tokenizer], attention_layers=[attention_layer_biomed, attention_layer_bert], filename='embeddings.csv'):
    assert isinstance(data, pd.DataFrame), "'data' debe ser un DataFrame de pandas"
    assert isinstance(modelos, list), "'modelos' debe ser una lista"
    assert isinstance(tokenizadores, list), "'tokenizadores' debe ser una lista"
    assert isinstance(attention_layers, list), "'attention_layers' debe ser una lista"
    assert len(modelos) == len(tokenizadores) == len(attention_layers), "Las listas 'modelos', 'tokenizadores' y 'attention_layers' deben tener la misma longitud"
    
    assert all(isinstance(modelo, tuple) and len(modelo) == 2 and isinstance(modelo[1], str) 
               for modelo in modelos), "Cada elemento de 'modelos' debe ser una tupla con al menos dos elementos, donde el segundo es un string"

    # Procesar cada pasaje y obtener los embeddings
    for ii in range(len(modelos)):
        model, model_name = modelos[ii]
        tokenizador = tokenizadores[ii]
        capa_atencion = attention_layers[ii]
        col_name = f'{model_name}_embeddings'

        data[col_name] = data.progress_apply(lambda row: process_text(row['cleaned_passage'], tokenizer=tokenizador, model=model, attention_layer=capa_atencion), axis=1)
        data[col_name] = data[col_name].apply(lambda x: x.tolist() if isinstance(x, np.ndarray) else x)
    
        # Guardar el DataFrame como un archivo CSV
        data.to_csv(f'{filename}.csv', index=False)

    return data


data_embeddings = exec_process(df, filename='embeddings')


ruta_embeddings = '/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/embeddings.csv'
data_embeddings = pd.read_csv(ruta_embeddings)


train_data, val_data = train_test_split(data_embeddings, test_size=0.2, random_state=42, stratify=data_embeddings['correctness'])


# etiquetas
y_train = train_data['correctness']
y_val = val_data['correctness']

# modelo biomedlm
X_biomedlm_train = np.array(train_data['biomed_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())
X_biomedlm_val = np.array(val_data['biomed_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())

# modelo bioclinicalbert
X_bioclinical_train = np.array(train_data['bioclinicalbert_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())
X_bioclinical_val = np.array(val_data['bioclinicalbert_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())

# modelo tfidf (convertimos matriz sparse a matriz densa)
vectorizer = TfidfVectorizer(max_features=5000)
X_tfidf_train = vectorizer.fit_transform(train_data['cleaned_passage']).toarray()
X_tfidf_val = vectorizer.transform(val_data['cleaned_passage']).toarray()





def modeloClasificacion(x_train, y_train, type_model, data_type, max_iter=100000, kernel='linear', nest=100, random_state=42):

    assert x_train is not None and y_train is not None, "Datos de entrenamiento no proporcionados"
    assert type_model in ['lr', 'svm', 'rf', 'xgb'], "Modelo no válido"

    # Inicializar modelo base
    if type_model == 'lr':
        model = LogisticRegression(max_iter=max_iter)
    elif type_model == 'svm':
        model = SVC(kernel=kernel, probability=True)
    elif type_model == 'rf':
        model = RandomForestClassifier(n_estimators=nest, random_state=random_state)
    elif type_model == 'xgb':
        model = XGBClassifier(eval_metric='logloss', random_state=random_state)

    model.fit(x_train, y_train)

    # Guardar el modelo en un archivo
    os.makedirs('modelos', exist_ok=True)
    joblib.dump(model, f'modelos/{type(model).__name__}_{data_type}_entrenado.pkl')
        
    return model

def cargar_modelo(filename, variable_name):
    assert isinstance(filename, str), "El nombre del archivo debe ser un string"
    return joblib.load('modelos/{filename}.pkl') if variable_name not in globals() else globals()[variable_name]



modelo_lr_biomedlm = modeloClasificacion(X_biomedlm_train, y_train, type_model='lr', data_type='biomedlm')
modelo_lr_bioclinical = modeloClasificacion(X_bioclinical_train, y_train, type_model='lr', data_type='bioclinical')
modelo_lr_tfidf = modeloClasificacion(X_tfidf_train, y_train, type_model='lr', data_type='tfidf')

modelo_svm_biomedlm = modeloClasificacion(X_biomedlm_train, y_train, type_model='svm', data_type='biomedlm')
modelo_svm_bioclinical = modeloClasificacion(X_bioclinical_train, y_train, type_model='svm', data_type='bioclinical')
modelo_svm_tfidf = modeloClasificacion(X_tfidf_train, y_train, type_model='svm', data_type='tfidf')

modelo_rf_biomedlm = modeloClasificacion(X_biomedlm_train, y_train, type_model='rf', data_type='biomedlm')
modelo_rf_bioclinical = modeloClasificacion(X_bioclinical_train, y_train, type_model='rf', data_type='bioclinical')
modelo_rf_tfidf = modeloClasificacion(X_tfidf_train, y_train, type_model='rf', data_type='tfidf')

modelo_xgb_biomedlm = modeloClasificacion(X_biomedlm_train, y_train, type_model='xgb', data_type='biomedlm')
modelo_xgb_bioclinical = modeloClasificacion(X_bioclinical_train, y_train, type_model='xgb', data_type='bioclinical')
modelo_xgb_tfidf = modeloClasificacion(X_tfidf_train, y_train, type_model='xgb', data_type='tfidf')




def evaluacion(y_true, y_pred):
    print(f"Accuracy: {accuracy_score(y_true, y_pred):.4f}")
    print("\nReporte de clasificación:")
    print(classification_report(y_true, y_pred))
    # Calcular matriz de confusión
    cm = confusion_matrix(y_true, y_pred)

    # Crear visualización
    fig, ax = plt.subplots(figsize=(6, 4))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax)
    ax.set_title('Matriz de Confusión')
    ax.set_xlabel('Predicción')
    ax.set_ylabel('Valor Real')
    plt.show()
    return 


def predicciones(x, modelo, y=None, data=None, filename=None, evaluation=evaluacion): # debe recibir el x_test_scaled
    assert len(x) == len(y) if y is not None else True, "Las filas de 'x' e 'y' no coinciden"
    assert hasattr(modelo, 'predict'), "Modelo no válido: el modelo no tiene un método 'predict'"

    predicciones = modelo.predict(x) # test (1-25 o 25-50)

    if y is not None:
        print(f"Modelo {type(modelo).__name__}")
        evaluation(y, predicciones)

    # cuando hacemos con datos de TEST (25-50)
    else:
        assert isinstance(data, pd.DataFrame), "'data' debe ser un DataFrame de pandas"
        assert filename is not None, "Se debe especificar un nombre para guardar el archivo"
        df_result = pd.DataFrame({
            'topic': data['topic'],
            'docId': data['docId'],
            'correctness': predicciones
        })

        # Guardar en un archivo CSV con separador de espacio
        os.makedirs('predicciones', exist_ok=True)
        df_result.to_csv(f'predicciones/{filename}.csv', sep=' ', index=False)
    
    if hasattr(modelo, 'predict_proba'):
        return [predicciones, modelo.predict_proba(x)]
    else:
        print(f"El modelo {type(modelo).__name__} no tiene un método 'predict_proba'")
        return predicciones
    

modelo_lr_biomedlm = cargar_modelo('LogisticRegression_biomedlm_entrenado.pkl', 'modelo_lr_biomedlm')
modelo_rf_biomedlm = cargar_modelo('RandomForestClassifier_biomedlm_entrenado.pkl', 'modelo_rf_biomedlm')
modelo_xgb_biomedlm = cargar_modelo('XGBClassifier_biomedlm_entrenado.pkl', 'modelo_xgb_biomedlm')
modelo_svm_biomedlm = cargar_modelo('SVC_biomedlm_entrenado.pkl', 'modelo_svm_biomedlm')

# predicciones
preds_lr_biomedlm = predicciones(X_biomedlm_val, modelo_lr_biomedlm, y=y_val)
preds_rf_biomedlm = predicciones(X_biomedlm_val, modelo_rf_biomedlm, y=y_val)
preds_xgb_biomedlm = predicciones(X_biomedlm_val, modelo_xgb_biomedlm, y=y_val)
preds_svm_biomedlm = predicciones(X_biomedlm_val, modelo_svm_biomedlm, y=y_val)


modelo_lr_bioclinical = cargar_modelo('LogisticRegression_bioclinical_entrenado.pkl', 'modelo_lr_bioclinical')
modelo_rf_bioclinical = cargar_modelo('RandomForestClassifier_bioclinical_entrenado.pkl', 'modelo_rf_bioclinical')
modelo_xgb_bioclinical = cargar_modelo('XGBClassifier_bioclinical_entrenado.pkl', 'modelo_xgb_bioclinical')
modelo_svm_bioclinical = cargar_modelo('SVC_bioclinical_entrenado.pkl', 'modelo_svm_bioclinical')

# predicciones
preds_lr_bioclinical = predicciones(X_bioclinical_val, modelo_lr_bioclinical, y=y_val)
preds_rf_bioclinical = predicciones(X_bioclinical_val, modelo_rf_bioclinical, y=y_val)
preds_xgb_bioclinical = predicciones(X_bioclinical_val, modelo_xgb_bioclinical, y=y_val)
preds_svm_bioclinical = predicciones(X_bioclinical_val, modelo_svm_bioclinical, y=y_val)


modelo_lr_tfidf = cargar_modelo('LogisticRegression_tfidf_entrenado.pkl', 'modelo_lr_tfidf')
modelo_rf_tfidf = cargar_modelo('RandomForestClassifier_tfidf_entrenado.pkl', 'modelo_rf_tfidf')
modelo_xgb_tfidf = cargar_modelo('XGBClassifier_tfidf_entrenado.pkl', 'modelo_xgb_tfidf')
modelo_svm_tfidf = cargar_modelo('SVC_tfidf_entrenado.pkl', 'modelo_svm_tfidf')

# predicciones
preds_lr_tfidf = predicciones(X_tfidf_val, modelo_lr_tfidf, y=y_val)
preds_rf_tfidf = predicciones(X_tfidf_val, modelo_rf_tfidf, y=y_val)
preds_xgb_tfidf = predicciones(X_tfidf_val, modelo_xgb_tfidf, y=y_val)
preds_svm_tfidf = predicciones(X_tfidf_val, modelo_svm_tfidf, y=y_val)




def combinacion(modelos, y_test=None, w = None, tipo='votacion', save=None, evaluation=evaluacion):
    assert isinstance(modelos, list), "'modelos' debe ser una lista de modelos"
    if w is not None:
        assert isinstance(w, list) , "'w' debe ser una lista"

    n = len(modelos)

    if tipo == 'votacion':
        predictions = [0] * len(modelos[0])
        for ii in range(len(modelos[0])):
            votes = [model[ii] for model in modelos]
            pred = max(set(votes), key=votes.count)
            predictions[ii] = pred
    
    elif tipo == 'promedio':
        w = [1 / n] * n if w is None else w
        numerador = sum(model * pesos for model, pesos in zip(modelos, w))
        predictions = np.argmax(numerador / n, axis=1)

    elif tipo == 'find_promedio':
        assert y_test is not None, "Se necesita proporcionar 'y_test' para encontrar los mejores pesos"
        valores = [ii / 10.0 for ii in range(10 * n + 1)] # valores de 0.0 a 1.0
        combinaciones = itertools.product(valores, repeat=n)
        combinaciones_validas = [comb for comb in combinaciones if np.isclose(sum(comb), float(n))]
        
        best_w = {}
        best_acc = 0
        predictions = None
        for pesos in combinaciones_validas:
            numerador = sum(model * pesos for model, pesos in zip(modelos, pesos))
            preds = np.argmax(numerador / n, axis=1)
            combined_accuracy = accuracy_score(y_test, preds)
            if combined_accuracy > best_acc:
                best_acc = combined_accuracy
                predictions = preds

            best_w[combined_accuracy] = pesos
        
        # Coger el modelo de mayor precisión
        assert best_acc == max(list(best_w.keys()))
        casi_buenos = [(elem, best_w[elem]) for elem in list(best_w.keys()) if elem > (best_acc - 0.01)]
        print(f"Otras combinaciones con precisión similar:\n" + "\n".join(map(str, casi_buenos)))
        print(f"Pesos del mejor modelo combinado: {best_w[best_acc]}", end=". ")
    
    else:
        raise ValueError("Tipo de combinación no válido")
    
    if y_test is not None:
        evaluation(y_test, predictions)
        return best_w[best_acc] if tipo == 'find_promedio' else None
    
    else:
        assert isinstance(save, list), "'save' debe ser una lista"
        data, filename = save
        assert isinstance(data, pd.DataFrame), "'data' debe ser un DataFrame de pandas"
        assert isinstance(filename, str), "'filename' debe ser un string"

        df_result = pd.DataFrame({
            'topic': data['topic'],
            'docId': data['docId'],
            'correctness': predictions
        })

        # Guardar en un archivo CSV con separador de espacio
        os.makedirs('predicciones', exist_ok=True)
        df_result.to_csv(f'predicciones/{filename}.csv', sep=' ', index=False)
        


combinacion([preds_xgb_biomedlm[0], preds_rf_biomedlm[0], preds_lr_bioclinical[0], preds_svm_tfidf[0]], y_test=y_val) # votacion mayoritaria
combinacion([preds_xgb_biomedlm[1], preds_rf_biomedlm[1], preds_lr_bioclinical[1], preds_lr_tfidf[1]], y_test=y_val, tipo='promedio') # promedio simple
best_weights = combinacion([preds_rf_biomedlm[1], preds_lr_bioclinical[1]], y_test=y_val, tipo='find_promedio') # encontrar mejores pesos


df_new = pd.read_csv('/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/ficheros necesarios/test_data_with_no_correctness_label.csv', sep=' ')
df_new = get_topics_from_xml(df_new, xml_file)
df_new['cleaned_passage'] = df_new['passage'].apply(clean_text)
df_new.to_csv('df_new.csv', index=False)


data_embeddings_new = exec_process(df_new, filename='embeddingsTest')

ruta_embeddings_new = '/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/embeddingsTest.csv'
data_embeddings_new = pd.read_csv(ruta_embeddings_new)

# modelo biomedlm
X_biomedlm_prueba = np.array(data_embeddings_new['biomed_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())

# modelo bioclinicalbert
X_bioclinical_prueba = np.array(data_embeddings_new['bioclinicalbert_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())

# modelo tfidf (convertimos matriz sparse a matriz densa)
X_tfidf_prueba = vectorizer.transform(data_embeddings_new['cleaned_passage']).toarray()

modelo_rf_biomedlm = cargar_modelo('RandomForestClassifier_biomedlm_entrenado.pkl', 'modelo_rf_biomedlm')
modelo_lr_bioclinical = cargar_modelo('LogisticRegression_bioclinical_entrenado.pkl', 'modelo_lr_bioclinical')
modelo_svm_tfidf = cargar_modelo('SVC_tfidf_entrenado.pkl', 'modelo_svm_tfidf')
modelo_rf_tfidf = cargar_modelo('RandomForestClassifier_tfidf_entrenado.pkl', 'modelo_rf_tfidf')
modelo_xgb_tfidf = cargar_modelo('XGBClassifier_tfidf_entrenado.pkl', 'modelo_xgb_tfidf')

# predicciones
preds_prueba_rf_biomedlm = predicciones(X_biomedlm_prueba, modelo_rf_biomedlm, data=df_new, filename='predicciones_rf_biomedlm')
preds_prueba_lr_bioclinical = predicciones(X_bioclinical_prueba, modelo_lr_bioclinical, data=df_new, filename='predicciones_lr_bioclinical')
preds_prueba_svm_tfidf = predicciones(X_tfidf_prueba, modelo_svm_tfidf, data=data_embeddings_new, filename='predicciones_svm_tfidf')
preds_prueba_rf_tfidf = predicciones(X_tfidf_prueba, modelo_rf_tfidf, data=data_embeddings_new, filename='predicciones_rf_tfidf')
preds_prueba_xgb_tfidf = predicciones(X_tfidf_prueba, modelo_xgb_tfidf, data=data_embeddings_new, filename='predicciones_xgb_tfidf')

combinacion([preds_prueba_rf_biomedlm[1], preds_prueba_lr_bioclinical[1]], w=list(best_weights), save=[df_new, 'rf_biomed_lr_bioclinical'], tipo='promedio') # promedio pesado




ruta_tabla = '/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/df.csv'
df2 = pd.read_csv(ruta_tabla)



# tokenizador y  modelo T5
tokenizer_T5 = T5Tokenizer.from_pretrained('t5-base')
modelo_T5 = T5ForConditionalGeneration.from_pretrained('t5-base')

def summarize(question, passage, model=modelo_T5, tokenizer=tokenizer_T5, max_length=500):
    # combinamos la pregunta y el pasaje
    input_text = f"summarize: question: {question} context: {passage}"
    # tokenizar el texto de entrada, sin truncar
    input_ids = tokenizer.encode(input_text, return_tensors='pt', max_length=None, truncation=False)
    # generamos un resumen de menos de 500 tokens
    summary_ids = model.generate(input_ids, max_length=max_length, min_length=100, 
                                 length_penalty=1.5, num_beams=4, early_stopping=True, 
                                 no_repeat_ngram_size=2)
    # decoding del resumen
    output = tokenizer.decode(summary_ids[0], skip_special_tokens=True)
    return output

def summarize_row(row, resumen=summarize):
    question = row['topic_text']
    passage = row['cleaned_passage']
    summary = resumen(question, passage)
    return summary

tqdm.pandas()

# longitud de los pasajes antes del resumen
df2['token_length'] = df2['cleaned_passage'].apply(lambda x: len(tokenizer_T5.tokenize(x)))

# resumimos y lo guardamos en el DataFrame
df2['cleaned_passage'] = df2.progress_apply(summarize_row, axis=1)

# longitud de los pasajes despues del resumen
df2['token_length'] = df2['cleaned_passage'].apply(lambda x: len(tokenizer_T5.tokenize(x)))

df2.to_csv(f'cleanT5.csv', index=False)

biomed_model = AutoModelForCausalLM.from_pretrained("stanford-crfm/BioMedLM")
bert_model = BertModel.from_pretrained('emilyalsentzer/Bio_ClinicalBERT', num_labels=2)

attention_layer_biomed = Attention(embed_dim=embed_dim_biomed)
attention_layer_bert = Attention(embed_dim=embed_dim_bert)

biomed_tokenizer = AutoTokenizer.from_pretrained("stanford-crfm/BioMedLM")
bert_tokenizer = BertTokenizer.from_pretrained('emilyalsentzer/Bio_ClinicalBERT')

data_embeddingsResumen = exec_process(df2, modelos=[(biomed_model, 'biomedlm'), (bert_model, 'bioclinicalbert')], tokenizadores=[biomed_tokenizer, bert_tokenizer], attention_layers=[attention_layer_biomed, attention_layer_bert], filename='embeddingsResumen')


ruta_embeddingsResumen = '/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/embeddingsResumen.csv'
data_embeddingsResumen = pd.read_csv(ruta_embeddingsResumen)

train_dataResumen, val_dataResumen = train_test_split(data_embeddingsResumen, test_size=0.2, random_state=42, stratify=data_embeddingsResumen['correctness'])

# etiquetas
y_trainResumen = train_dataResumen['correctness']
y_valResumen = val_dataResumen['correctness']

# modelo biomedlm
X_biomedlm_trainResumen = np.array(train_dataResumen['biomedlm_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())
X_biomedlm_valResumen = np.array(val_dataResumen['biomedlm_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())

# modelo bioclinicalbert
X_bioclinical_trainResumen = np.array(train_dataResumen['bioclinicalbert_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())
X_bioclinical_valResumen = np.array(val_dataResumen['bioclinicalbert_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())

# modelo tfidf (convertimos matriz sparse a matriz densa)
vectorizer = TfidfVectorizer(max_features=5000)
X_tfidf_trainResumen = vectorizer.fit_transform(train_dataResumen['cleaned_passage']).toarray()
X_tfidf_valResumen = vectorizer.transform(val_dataResumen['cleaned_passage']).toarray()


modelo_lr_biomedlmResumen = modeloClasificacion(X_biomedlm_trainResumen, y_trainResumen, type_model='lr', data_type='biomedlm_resumen')
modelo_lr_bioclinicalResumen = modeloClasificacion(X_bioclinical_trainResumen, y_trainResumen, type_model='lr', data_type='bioclinical_resumen')
modelo_lr_tfidfResumen = modeloClasificacion(X_tfidf_trainResumen, y_trainResumen, type_model='lr', data_type='tfidf_resumen')

modelo_svm_biomedlmResumen = modeloClasificacion(X_biomedlm_trainResumen, y_trainResumen, type_model='svm', data_type='biomedlm_resumen')
modelo_svm_bioclinicalResumen = modeloClasificacion(X_bioclinical_trainResumen, y_trainResumen, type_model='svm', data_type='bioclinical_resumen')
modelo_svm_tfidfResumen = modeloClasificacion(X_tfidf_trainResumen, y_trainResumen, type_model='svm', data_type='tfidf_resumen')

modelo_rf_biomedlmResumen = modeloClasificacion(X_biomedlm_trainResumen, y_trainResumen, type_model='rf', data_type='biomedlm_resumen')
modelo_rf_bioclinicalResumen = modeloClasificacion(X_bioclinical_trainResumen, y_trainResumen, type_model='rf', data_type='bioclinical_resumen')
modelo_rf_tfidfResumen = modeloClasificacion(X_tfidf_trainResumen, y_trainResumen, type_model='rf', data_type='tfidf_resumen')

modelo_xgb_biomedlmResumen = modeloClasificacion(X_biomedlm_trainResumen, y_trainResumen, type_model='xgb', data_type='biomedlm_resumen')
modelo_xgb_bioclinicalResumen = modeloClasificacion(X_bioclinical_trainResumen, y_trainResumen, type_model='xgb', data_type='bioclinical_resumen')
modelo_xgb_tfidfResumen = modeloClasificacion(X_tfidf_trainResumen, y_trainResumen, type_model='xgb', data_type='tfidf_resumen')

modelo_lr_biomedlmResumen = cargar_modelo('LogisticRegression_biomedlm_resumen_entrenado.pkl', 'modelo_lr_biomedlmResumen')
modelo_rf_biomedlmResumen = cargar_modelo('RandomForestClassifier_biomedlm_resumen_entrenado.pkl', 'modelo_rf_biomedlmResumen')
modelo_xgb_biomedlmResumen = cargar_modelo('XGBClassifier_biomedlm_resumen_entrenado.pkl', 'modelo_xgb_biomedlmResumen')
modelo_svm_biomedlmResumen = cargar_modelo('SVC_biomedlm_resumen_entrenado.pkl', 'modelo_svm_biomedlmResumen')

# predicciones
preds_lr_biomedlmResumen = predicciones(X_biomedlm_valResumen, modelo_lr_biomedlmResumen, y=y_valResumen)
preds_rf_biomedlmResumen = predicciones(X_biomedlm_valResumen, modelo_rf_biomedlmResumen, y=y_valResumen)
preds_xgb_biomedlmResumen = predicciones(X_biomedlm_valResumen, modelo_xgb_biomedlmResumen, y=y_valResumen)
preds_svm_biomedlmResumen = predicciones(X_biomedlm_valResumen, modelo_svm_biomedlmResumen, y=y_valResumen)

modelo_lr_bioclinicalResumen = cargar_modelo('LogisticRegression_bioclinical_resumen_entrenado.pkl', 'modelo_lr_bioclinicalResumen')
modelo_rf_bioclinicalResumen = cargar_modelo('RandomForestClassifier_bioclinical_resumen_entrenado.pkl', 'modelo_rf_bioclinicalResumen')
modelo_xgb_bioclinicalResumen = cargar_modelo('XGBClassifier_bioclinical_resumen_entrenado.pkl', 'modelo_xgb_bioclinicalResumen')
modelo_svm_bioclinicalResumen = cargar_modelo('SVC_bioclinical_resumen_entrenado.pkl', 'modelo_svm_bioclinicalResumen')

# predicciones
preds_lr_bioclinicalResumen = predicciones(X_bioclinical_valResumen, modelo_lr_bioclinicalResumen, y=y_valResumen)
preds_rf_bioclinicalResumen = predicciones(X_bioclinical_valResumen, modelo_rf_bioclinicalResumen, y=y_valResumen)
preds_xgb_bioclinicalResumen = predicciones(X_bioclinical_valResumen, modelo_xgb_bioclinicalResumen, y=y_valResumen)
preds_svm_bioclinicalResumen = predicciones(X_bioclinical_valResumen, modelo_svm_bioclinicalResumen, y=y_valResumen)

modelo_lr_tfidfResumen = cargar_modelo('LogisticRegression_tfidf_resumen_entrenado.pkl', 'modelo_lr_tfidfResumen')
modelo_rf_tfidfResumen = cargar_modelo('RandomForestClassifier_tfidf_resumen_entrenado.pkl', 'modelo_rf_tfidfResumen')
modelo_xgb_tfidfResumen = cargar_modelo('XGBClassifier_tfidf_resumen_entrenado.pkl', 'modelo_xgb_tfidfResumen')
modelo_svm_tfidfResumen = cargar_modelo('SVC_tfidf_resumen_entrenado.pkl', 'modelo_svm_tfidfResumen')

# predicciones
preds_lr_tfidfResumen = predicciones(X_tfidf_valResumen, modelo_lr_tfidfResumen, y=y_valResumen)
preds_rf_tfidfResumen = predicciones(X_tfidf_valResumen, modelo_rf_tfidfResumen, y=y_valResumen)
preds_xgb_tfidfResumen = predicciones(X_tfidf_valResumen, modelo_xgb_tfidfResumen, y=y_valResumen)
preds_svm_tfidfResumen = predicciones(X_tfidf_valResumen, modelo_svm_tfidfResumen, y=y_valResumen)

combinacion([preds_xgb_biomedlmResumen[0], preds_lr_bioclinicalResumen[0], preds_rf_tfidfResumen[0]], y_test=y_valResumen) # votacion mayoritaria
combinacion([preds_xgb_biomedlmResumen[1], preds_lr_bioclinicalResumen[1], preds_rf_tfidfResumen[1]], y_test=y_valResumen, tipo='promedio') # promedio simple
best_weightsResumen = combinacion([preds_xgb_biomedlmResumen[1], preds_lr_bioclinicalResumen[1], preds_rf_tfidfResumen[1], preds_svm_tfidfResumen[1]], y_test=y_valResumen, tipo='find_promedio') # encontrar mejores pesos


ruta_tablaTest = '/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/df_new.csv'
df_testResumen = pd.read_csv(ruta_tablaTest)

# tokenizador y  modelo T5
tokenizer_T5 = T5Tokenizer.from_pretrained('t5-base')
modelo_T5 = T5ForConditionalGeneration.from_pretrained('t5-base')

tqdm.pandas()

# longitud de los pasajes antes del resumen
df_testResumen['token_length'] = df_testResumen['cleaned_passage'].apply(lambda x: len(tokenizer_T5.tokenize(x)))

# resumimos y lo guardamos en el DataFrame
df_testResumen['cleaned_passage'] = df_testResumen.progress_apply(summarize_row, axis=1)

# longitud de los pasajes despues del resumen
df_testResumen['token_length'] = df_testResumen['cleaned_passage'].apply(lambda x: len(tokenizer_T5.tokenize(x)))

df_testResumen.to_csv(f'cleanT5_test.csv', index=False)

data_embeddingsResumen_test = exec_process(df_testResumen, modelos=[(biomed_model, 'biomedlm'), (bert_model, 'bioclinicalbert')], tokenizadores=[biomed_tokenizer, bert_tokenizer], attention_layers=[attention_layer_biomed, attention_layer_bert], filename='embeddingsResumen_test')

ruta_embeddingsResumen_test = '/Users/luisi/Documents/Master-Big-Data/Tecnologías de gestión de información no estructurada/Practica/Reto/embeddingsResumen_test.csv'
data_embeddingsResumen_test = pd.read_csv(ruta_embeddingsResumen_test, sep=',')

# modelo biomedlm
X_biomedlm_testResumen = np.array(data_embeddingsResumen_test['biomedlm_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())

# modelo bioclinicalbert
X_bioclinical_testResumen = np.array(data_embeddingsResumen_test['bioclinicalbert_embeddings'].apply(lambda x: np.squeeze(np.array(ast.literal_eval(x)))).tolist())

# modelo tfidf (convertimos matriz sparse a matriz densa)
X_tfidf_testResumen = vectorizer.transform(data_embeddingsResumen_test['cleaned_passage']).toarray()

modelo_lr_bioclinicalResumen = cargar_modelo('LogisticRegression_bioclinical_resumen_entrenado.pkl', 'modelo_lr_bioclinicalResumen')
modelo_xgb_biomedlmResumen = cargar_modelo('XGBClassifier_biomedlm_resumen_entrenado.pkl', 'modelo_xgb_biomedlmResumen')
modelo_rf_tfidfResumen = cargar_modelo('RandomForestClassifier_tfidf_resumen_entrenado.pkl', 'modelo_rf_tfidfResumen')
modelo_svm_tfidfResumen = cargar_modelo('SVC_tfidf_resumen_entrenado.pkl', 'modelo_svm_tfidfResumen')

# predicciones
preds_xgb_biomedlm_testResumen = predicciones(X_biomedlm_testResumen, modelo_xgb_biomedlmResumen, data=data_embeddingsResumen_test, filename='predicciones_xgb_biomedlm_testResumen')
preds_lr_bioclinical_testResumen = predicciones(X_bioclinical_testResumen, modelo_lr_bioclinicalResumen, data=data_embeddingsResumen_test, filename='predicciones_lr_bioclinical_testResumen')
preds_svm_tfidf_testResumen = predicciones(X_tfidf_testResumen, modelo_svm_tfidfResumen, data=data_embeddingsResumen_test, filename='predicciones_svm_tfidf_testResumen')
preds_rf_tfidf_testResumen = predicciones(X_tfidf_testResumen, modelo_rf_tfidfResumen, data=data_embeddingsResumen_test, filename='predicciones_rf_tfidf_testResumen')

combinacion([preds_xgb_biomedlm_testResumen[1], preds_lr_bioclinical_testResumen[1], preds_rf_tfidf_testResumen[1], preds_svm_tfidf_testResumen[1]], w=list(best_weightsResumen), save=[data_embeddingsResumen_test, 'xgb_biomedResumen_lr_bioclinicalResumen_rf_svm_tfidfResumen'], tipo='promedio') # promedio pesado




def mejorModeloClasificacion(x_train, y_train, type_model, data_type, param_grid=None, cv=5, scoring='accuracy', random_state=42):
    assert x_train is not None and y_train is not None, "Datos de entrenamiento no proporcionados"
    assert type_model in ['lr', 'svm', 'rf', 'xgb'], "Modelo no válido"

    # Inicializar modelo base y parámetros por defecto si no se proporcionan
    if type_model == 'lr':
        model = LogisticRegression(random_state=random_state, max_iter=10000)
        if param_grid is None:
            param_grid = {
                'C': [0.01, 0.1, 1, 10],
                'penalty': ['l2'],
                'solver': ['liblinear', 'saga']
            }
    elif type_model == 'svm':
        model = SVC(probability=True, random_state=random_state)
        if param_grid is None:
            param_grid = {
                'C': [0.1, 1, 10],
                'kernel': ['linear', 'rbf', 'poly'],
                'gamma': ['scale', 'auto']
            }
    elif type_model == 'rf':
        model = RandomForestClassifier(random_state=random_state)
        if param_grid is None:
            param_grid = {
                'n_estimators': [50, 100, 200, 300],
                'min_samples_leaf': [1, 2, 4]
            }
    elif type_model == 'xgb':
        model = XGBClassifier(eval_metric='logloss', random_state=random_state)
        if param_grid is None:
            param_grid = {
                'n_estimators': [50, 100, 200, 300],
                'min_child_weight': [1, 3, 5],
                'learning_rate': [0.01, 0.1, 0.2]
            }
    
    grid_search = GridSearchCV(estimator=model, param_grid=param_grid, 
                               cv=cv, scoring=scoring, n_jobs=-1)
    
    grid_search.fit(x_train, y_train)

    # Obtener el mejor modelo
    best_model = grid_search.best_estimator_

    # Guardar el mejor modelo
    os.makedirs('modelos', exist_ok=True)
    model_filename = f"{type(best_model).__name__}_{data_type}_mejor_modelo.pkl"
    joblib.dump(best_model, f'modelos/{model_filename}')

    print(f"Mejores hiperparámetros para {type_model}: {grid_search.best_params_}")
    print(f"Mejor puntuación ({scoring}): {grid_search.best_score_:.4f}")
    print(f"Modelo guardado como: {model_filename}")

    return best_model


os.environ["TOKENIZERS_PARALLELISM"] = "false" # desactivar un warning

best_modelo_lr_biomedlm = mejorModeloClasificacion(X_biomedlm_train, y_train, type_model='lr', data_type='biomedlmBEST')
best_modelo_lr_bioclinical = mejorModeloClasificacion(X_bioclinical_train, y_train, type_model='lr', data_type='bioclinicalBEST')
best_modelo_lr_tfidf = mejorModeloClasificacion(X_tfidf_train, y_train, type_model='lr', data_type='tfidfBEST')

best_modelo_svm_biomedlm = mejorModeloClasificacion(X_biomedlm_train, y_train, type_model='svm', data_type='biomedlmBEST')
best_modelo_svm_bioclinical = mejorModeloClasificacion(X_bioclinical_train, y_train, type_model='svm', data_type='bioclinicalBEST')
best_modelo_svm_tfidf = mejorModeloClasificacion(X_tfidf_train, y_train, type_model='svm', data_type='tfidfBEST')

best_modelo_rf_biomedlm = mejorModeloClasificacion(X_biomedlm_train, y_train, type_model='rf', data_type='biomedlmBEST')
best_modelo_rf_bioclinical = mejorModeloClasificacion(X_bioclinical_train, y_train, type_model='rf', data_type='bioclinicalBEST')
best_modelo_rf_tfidf = mejorModeloClasificacion(X_tfidf_train, y_train, type_model='rf', data_type='tfidfBEST')

best_modelo_xgb_biomedlm = mejorModeloClasificacion(X_biomedlm_train, y_train, type_model='xgb', data_type='biomedlmBEST')
best_modelo_xgb_bioclinical = mejorModeloClasificacion(X_bioclinical_train, y_train, type_model='xgb', data_type='bioclinicalBEST')
best_modelo_xgb_tfidf = mejorModeloClasificacion(X_tfidf_train, y_train, type_model='xgb', data_type='tfidfBEST')

best_modelo_lr_biomedlm = cargar_modelo('LogisticRegression_biomedlmBEST_mejor_modelo.pkl', 'best_modelo_lr_biomedlm')
best_modelo_rf_biomedlm = cargar_modelo('RandomForestClassifier_biomedlmBEST_mejor_modelo.pkl', 'best_modelo_rf_biomedlm')
best_modelo_xgb_biomedlm = cargar_modelo('XGBClassifier_biomedlmBEST_mejor_modelo.pkl', 'best_modelo_xgb_biomedlm')
best_modelo_svm_biomedlm = cargar_modelo('SVC_biomedlmBEST_mejor_modelo.pkl', 'best_modelo_svm_biomedlm')

# predicciones
best_preds_lr_biomedlm = predicciones(X_biomedlm_val, best_modelo_lr_biomedlm, y=y_val)
best_preds_rf_biomedlm = predicciones(X_biomedlm_val, best_modelo_rf_biomedlm, y=y_val)
best_preds_xgb_biomedlm = predicciones(X_biomedlm_val, best_modelo_xgb_biomedlm, y=y_val)
best_preds_svm_biomedlm = predicciones(X_biomedlm_val, best_modelo_svm_biomedlm, y=y_val)

best_modelo_lr_bioclinical = cargar_modelo('LogisticRegression_bioclinicalBEST_mejor_modelo.pkl', 'best_modelo_lr_bioclinical')
best_modelo_rf_bioclinical = cargar_modelo('RandomForestClassifier_bioclinicalBEST_mejor_modelo.pkl', 'best_modelo_rf_bioclinical')
best_modelo_xgb_bioclinical = cargar_modelo('XGBClassifier_bioclinicalBEST_mejor_modelo.pkl', 'best_modelo_xgb_bioclinical')
best_modelo_svm_bioclinical = cargar_modelo('SVC_bioclinicalBEST_mejor_modelo.pkl', 'best_modelo_svm_bioclinical')

# predicciones
best_preds_lr_bioclinical = predicciones(X_bioclinical_val, best_modelo_lr_bioclinical, y=y_val)
best_preds_rf_bioclinical = predicciones(X_bioclinical_val, best_modelo_rf_bioclinical, y=y_val)
best_preds_xgb_bioclinical = predicciones(X_bioclinical_val, best_modelo_xgb_bioclinical, y=y_val)
best_preds_svm_bioclinical = predicciones(X_bioclinical_val, best_modelo_svm_bioclinical, y=y_val)

best_modelo_lr_tfidf = cargar_modelo('LogisticRegression_tfidfBEST_mejor_modelo.pkl', 'best_modelo_lr_tfidf')
best_modelo_rf_tfidf = cargar_modelo('RandomForestClassifier_tfidfBEST_mejor_modelo.pkl', 'best_modelo_rf_tfidf')
best_modelo_xgb_tfidf = cargar_modelo('XGBClassifier_tfidfBEST_mejor_modelo.pkl', 'best_modelo_xgb_tfidf')
best_modelo_svm_tfidf = cargar_modelo('SVC_tfidfBEST_mejor_modelo.pkl', 'best_modelo_svm_tfidf')

# predicciones
best_preds_lr_tfidf = predicciones(X_tfidf_val, best_modelo_lr_tfidf, y=y_val)
best_preds_rf_tfidf = predicciones(X_tfidf_val, best_modelo_rf_tfidf, y=y_val)
best_preds_xgb_tfidf = predicciones(X_tfidf_val, best_modelo_xgb_tfidf, y=y_val)
best_preds_svm_tfidf = predicciones(X_tfidf_val, best_modelo_svm_tfidf, y=y_val)

best_weightsCV = combinacion([best_preds_svm_biomedlm[1], best_preds_xgb_bioclinical[1], best_preds_svm_bioclinical[1], best_preds_lr_tfidf[1], best_preds_rf_tfidf[1]], y_test=y_val, tipo='find_promedio') # encontrar mejores pesos

best_modelo_svm_biomedlm = cargar_modelo('SVC_biomedlmBEST_mejor_modelo.pkl', 'best_modelo_svm_biomedlm')
best_modelo_xgb_bioclinical = cargar_modelo('XGBClassifier_bioclinicalBEST_mejor_modelo.pkl', 'best_modelo_xgb_bioclinical')
best_modelo_svm_bioclinical = cargar_modelo('SVC_bioclinicalBEST_mejor_modelo.pkl', 'best_modelo_svm_bioclinical')
best_modelo_lr_tfidf = cargar_modelo('LogisticRegression_tfidfBEST_mejor_modelo.pkl', 'best_modelo_lr_tfidf')
best_modelo_rf_tfidf = cargar_modelo('RandomForestClassifier_tfidfBEST_mejor_modelo.pkl', 'best_modelo_rf_tfidf')

best_preds_svm_biomedlm_test = predicciones(X_biomedlm_prueba, best_modelo_svm_biomedlm, data=df_new, filename='best_predicciones_svm_biomedlm_test')
best_preds_xgb_bioclinical_test = predicciones(X_bioclinical_prueba, best_modelo_xgb_bioclinical, data=df_new, filename='best_predicciones_xgb_bioclinical_test')
best_preds_svm_bioclinical_test = predicciones(X_bioclinical_prueba, best_modelo_svm_bioclinical, data=df_new, filename='best_predicciones_svm_bioclinical_test')
best_preds_lr_tfidf_test = predicciones(X_tfidf_prueba, best_modelo_lr_tfidf, data=df_new, filename='best_predicciones_lr_tfidf_test')
best_preds_rf_tfidf_test = predicciones(X_tfidf_prueba, best_modelo_rf_tfidf, data=df_new, filename='best_predicciones_rf_tfidf_test')

combinacion([best_preds_svm_biomedlm_test[1], best_preds_xgb_bioclinical_test[1], best_preds_svm_bioclinical_test[1], best_preds_lr_tfidf_test[1], best_preds_rf_tfidf_test[1]], w=list(best_weightsCV), save=[df_new, 'best_svm_biomed_xgb_svm_bioclinical_lr_rf_tfidf'], tipo='promedio') # promedio pesado



# resumidos 
import os
os.environ["TOKENIZERS_PARALLELISM"] = "false"

best_modelo_lr_biomedlmResumen = mejorModeloClasificacion(X_biomedlm_trainResumen, y_trainResumen, type_model='lr', data_type='biomedlmResumenBEST')
best_modelo_lr_bioclinicalResumen = mejorModeloClasificacion(X_bioclinical_trainResumen, y_trainResumen, type_model='lr', data_type='bioclinicalResumenBEST')
best_modelo_lr_tfidfResumen = mejorModeloClasificacion(X_tfidf_trainResumen, y_trainResumen, type_model='lr', data_type='tfidfResumenBEST')

best_modelo_svm_biomedlmResumen = mejorModeloClasificacion(X_biomedlm_trainResumen, y_trainResumen, type_model='svm', data_type='biomedlmResumenBEST')
best_modelo_svm_bioclinicalResumen = mejorModeloClasificacion(X_bioclinical_trainResumen, y_trainResumen, type_model='svm', data_type='bioclinicalResumenBEST')
best_modelo_svm_tfidfResumen = mejorModeloClasificacion(X_tfidf_trainResumen, y_trainResumen, type_model='svm', data_type='tfidfResumenBEST')

best_modelo_rf_biomedlmResumen = mejorModeloClasificacion(X_biomedlm_trainResumen, y_trainResumen, type_model='rf', data_type='biomedlmResumenBEST')
best_modelo_rf_bioclinicalResumen = mejorModeloClasificacion(X_bioclinical_trainResumen, y_trainResumen, type_model='rf', data_type='bioclinicalResumenBEST')
best_modelo_rf_tfidfResumen = mejorModeloClasificacion(X_tfidf_trainResumen, y_trainResumen, type_model='rf', data_type='tfidfResumenBEST')

best_modelo_xgb_biomedlmResumen = mejorModeloClasificacion(X_biomedlm_trainResumen, y_trainResumen, type_model='xgb', data_type='biomedlmResumenBEST')
best_modelo_xgb_bioclinicalResumen = mejorModeloClasificacion(X_bioclinical_trainResumen, y_trainResumen, type_model='xgb', data_type='bioclinicalResumenBEST')
best_modelo_xgb_tfidfResumen = mejorModeloClasificacion(X_tfidf_trainResumen, y_trainResumen, type_model='xgb', data_type='tfidfResumenBEST')

best_modelo_lr_biomedlmResumen = cargar_modelo('LogisticRegression_biomedlmResumenBEST_mejor_modelo.pkl', 'best_modelo_lr_biomedlmResumen')
best_modelo_rf_biomedlmResumen = cargar_modelo('RandomForestClassifier_biomedlmResumenBEST_mejor_modelo.pkl', 'best_modelo_rf_biomedlmResumen')
best_modelo_xgb_biomedlmResumen = cargar_modelo('XGBClassifier_biomedlmResumenBEST_mejor_modelo.pkl', 'best_modelo_xgb_biomedlmResumen')
best_modelo_svm_biomedlmResumen = cargar_modelo('SVC_biomedlmResumenBEST_mejor_modelo.pkl', 'best_modelo_svm_biomedlmResumen')

# predicciones
best_preds_lr_biomedlmResumen = predicciones(X_biomedlm_valResumen, best_modelo_lr_biomedlmResumen, y=y_valResumen)
best_preds_rf_biomedlmResumen = predicciones(X_biomedlm_valResumen, best_modelo_rf_biomedlmResumen, y=y_valResumen)
best_preds_xgb_biomedlmResumen = predicciones(X_biomedlm_valResumen, best_modelo_xgb_biomedlmResumen, y=y_valResumen)
best_preds_svm_biomedlmResumen = predicciones(X_biomedlm_valResumen, best_modelo_svm_biomedlmResumen, y=y_valResumen)

best_modelo_lr_bioclinicalResumen = cargar_modelo('LogisticRegression_bioclinicalResumenBEST_mejor_modelo.pkl', 'best_modelo_lr_bioclinicalResumen')
best_modelo_rf_bioclinicalResumen = cargar_modelo('RandomForestClassifier_bioclinicalResumenBEST_mejor_modelo.pkl', 'best_modelo_rf_bioclinicalResumen')
best_modelo_xgb_bioclinicalResumen = cargar_modelo('XGBClassifier_bioclinicalResumenBEST_mejor_modelo.pkl', 'best_modelo_xgb_bioclinicalResumen')
best_modelo_svm_bioclinicalResumen = cargar_modelo('SVC_bioclinicalResumenBEST_mejor_modelo.pkl', 'best_modelo_svm_bioclinicalResumen')

# predicciones
best_preds_lr_bioclinicalResumen = predicciones(X_bioclinical_valResumen, best_modelo_lr_bioclinicalResumen, y=y_valResumen)
best_preds_rf_bioclinicalResumen = predicciones(X_bioclinical_valResumen, best_modelo_rf_bioclinicalResumen, y=y_valResumen)
best_preds_xgb_bioclinicalResumen = predicciones(X_bioclinical_valResumen, best_modelo_xgb_bioclinicalResumen, y=y_valResumen)
best_preds_svm_bioclinicalResumen = predicciones(X_bioclinical_valResumen, best_modelo_svm_bioclinicalResumen, y=y_valResumen)

best_modelo_lr_tfidfResumen = cargar_modelo('LogisticRegression_tfidfResumenBEST_mejor_modelo.pkl', 'best_modelo_lr_tfidfResumen')
best_modelo_rf_tfidfResumen = cargar_modelo('RandomForestClassifier_tfidfResumenBEST_mejor_modelo.pkl', 'best_modelo_rf_tfidfResumen')
best_modelo_xgb_tfidfResumen = cargar_modelo('XGBClassifier_tfidfResumenBEST_mejor_modelo.pkl', 'best_modelo_xgb_tfidfResumen')
best_modelo_svm_tfidfResumen = cargar_modelo('SVC_tfidfResumenBEST_mejor_modelo.pkl', 'best_modelo_svm_tfidfResumen')

# predicciones
best_preds_lr_tfidfResumen = predicciones(X_tfidf_valResumen, best_modelo_lr_tfidfResumen, y=y_valResumen)
best_preds_rf_tfidfResumen = predicciones(X_tfidf_valResumen, best_modelo_rf_tfidfResumen, y=y_valResumen)
best_preds_xgb_tfidfResumen = predicciones(X_tfidf_valResumen, best_modelo_xgb_tfidfResumen, y=y_valResumen)
best_preds_svm_tfidfResumen = predicciones(X_tfidf_valResumen, best_modelo_svm_tfidfResumen, y=y_valResumen)

best_weightsCVResumen = combinacion([best_preds_rf_biomedlmResumen[1], best_preds_svm_bioclinicalResumen[1], best_preds_rf_tfidfResumen[1], best_preds_svm_tfidfResumen[1]], y_test=y_val, tipo='find_promedio') # encontrar mejores pesos


best_modelo_rf_biomedlmResumen = cargar_modelo('RandomForestClassifier_biomedlmBEST_mejor_modelo.pkl', 'best_modelo_rf_biomedlmResuem')
best_modelo_svm_bioclinicalResumen = cargar_modelo('SVC_bioclinicalBEST_mejor_modelo.pkl', 'best_modelo_svm_bioclinicalResumen')
best_modelo_svm_tfidfResumen = cargar_modelo('SVC_tfidfBEST_mejor_modelo.pkl', 'best_modelo_svm_tfidfResumen')
best_modelo_rf_tfidfResumen = cargar_modelo('RandomForestClassifier_tfidfBEST_mejor_modelo.pkl', 'best_modelo_rf_tfidfResumen')

best_preds_rf_biomedlm_testResumen = predicciones(X_biomedlm_testResumen, best_modelo_rf_biomedlmResumen, data=data_embeddingsResumen_test, filename='best_predicciones_svm_biomedlm_testResumen')
best_preds_svm_bioclinical_testResumen = predicciones(X_bioclinical_testResumen, best_modelo_svm_bioclinicalResumen, data=data_embeddingsResumen_test, filename='best_predicciones_svm_bioclinical_testResumen')
best_preds_svm_tfidf_testResumen = predicciones(X_tfidf_testResumen, best_modelo_svm_tfidfResumen, data=data_embeddingsResumen_test, filename='best_predicciones_lr_tfidf_testResumen')
best_preds_rf_tfidf_testResumen = predicciones(X_tfidf_testResumen, best_modelo_rf_tfidfResumen, data=data_embeddingsResumen_test, filename='best_predicciones_rf_tfidf_testResumen')

# combinamos las predicciones
combinacion([best_preds_rf_biomedlm_testResumen[1], best_preds_svm_bioclinical_testResumen[1], best_preds_rf_tfidf_testResumen[1], best_preds_svm_tfidf_testResumen[1]], w=list(best_weightsCVResumen), save=[data_embeddingsResumen_test, 'best_testResumen_svm_biomed_xgb_svm_bioclinical_lr_rf_tfidf'], tipo='promedio') # promedio pesado