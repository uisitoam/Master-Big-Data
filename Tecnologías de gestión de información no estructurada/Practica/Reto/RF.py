import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics import accuracy_score

# Cargar el dataset
data = pd.read_csv('/Users/luisi/Documents/Master/1. Tecnologías de gestión de información no estructurada/Practica/Reto/ficheros necesarios/training_data.csv', sep=' ')
print(f"Dataset cargado con shape: {data.shape}")

# Remover la primera fila si es un encabezado repetido
if data.iloc[0].equals(data.columns):
    print("Removiendo encabezado repetido en la primera fila...")
    data = data.drop(0)

# Convertir la columna 'correctness' a enteros, asegurando que no haya valores inválidos
data['correctness'] = pd.to_numeric(data['correctness'], errors='coerce')
data = data.dropna(subset=['correctness'])  # Eliminar filas con NaN en 'correctness'
data['correctness'] = data['correctness'].astype(int)
print(f"Shape de los datos después de limpiar: {data.shape}")

# Extraer las columnas relevantes
X = data['passage']
y = data['correctness']
doc_ids = data['docId']  # Extraer la columna 'docId'
topics = data['topic']  # Extraer la columna 'topic'
print(f"Número de pasajes: {len(X)}, Número de etiquetas: {len(y)}")

# Usar TF-IDF para convertir el texto en features numéricos
vectorizer = TfidfVectorizer(max_features=5000)
X_vectorized = vectorizer.fit_transform(X)

# Dividir los datos en conjuntos de entrenamiento y prueba
X_train, X_test, y_train, y_test, doc_ids_train, doc_ids_test, topics_train, topics_test = train_test_split(
    X_vectorized, y, doc_ids, topics, test_size=0.2, random_state=42
)
print(f"División de datos completa. Tamaño de entrenamiento: {X_train.shape}, Tamaño de prueba: {X_test.shape}")

# Entrenar un modelo Random Forest
clf = RandomForestClassifier(n_estimators=100)
clf.fit(X_train, y_train)
print("Entrenamiento del modelo completado.")

# Predecir en el conjunto de prueba
y_pred = clf.predict(X_test)

# Calcular la precisión en el conjunto de prueba
accuracy = accuracy_score(y_test, y_pred)
print(f"Precisión en el conjunto de prueba: {accuracy:.2f}")

# Cargar el dataset de prueba
dataTEST = pd.read_csv('/Users/luisi/Documents/Master/1. Tecnologías de gestión de información no estructurada/Practica/Reto/ficheros necesarios/test_data_with_no_correctness_label.csv', sep=' ')
print(f"Dataset cargado con shape: {dataTEST.shape}")

# Remover la primera fila si es un encabezado repetido
if dataTEST.iloc[0].equals(dataTEST.columns):
    print("Removiendo encabezado repetido en la primera fila...")
    dataTEST = dataTEST.drop(0)

# Extraer las columnas relevantes
XTEST = dataTEST['passage']
doc_idsTEST = dataTEST['docId']  # Extraer la columna 'docId'
topicsTEST = dataTEST['topic']  # Extraer la columna 'topic'

# Usar el mismo vectorizador TF-IDF para convertir el texto de prueba en features numéricos
X_vectorizedTEST = vectorizer.transform(XTEST)

# Predecir en el conjunto de prueba
y_predTEST = clf.predict(X_vectorizedTEST)

# Generar el DataFrame de predicciones en el formato solicitado
test_data_dfTEST = pd.DataFrame({
    'topic': dataTEST['topic'],    # Usar los valores reales de 'topic'
    'docId': dataTEST['docId'],    # Usar los valores reales de 'docId'
    'correctness': y_predTEST     # Predicciones del modelo
})

# Guardar en un archivo CSV con separador de espacio
test_data_dfTEST.to_csv('prediccionesRF.csv', sep=' ', index=False)

print("Archivo guardado como 'prediccionesRF.csv'")