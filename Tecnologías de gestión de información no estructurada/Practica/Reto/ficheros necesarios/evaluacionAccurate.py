import pandas as pd 
import numpy as np

gt = pd.read_csv('/Users/luisi/Documents/Master/1. Tecnologías de gestión de información no estructurada/Practica/Reto/ficheros necesarios/training_data.csv', sep=' ')
print(gt.head())

prediction_file='/Users/luisi/Documents/Master/1. Tecnologías de gestión de información no estructurada/Practica/Reto/ficheros necesarios/predicciones_trainingk10.csv'

preds = pd.read_csv(prediction_file, sep=' ')
print(preds.head())

tpos=0
tneg=0
fpos=0
fneg=0


for index, row in gt.iterrows():
    #print(f"Index: {index}")
    
    gtID = row['docId']
    gtlabel = row['correctness']
    gttopic = row['topic']
    
    tpreds = preds.loc[preds['topic'] == gttopic] #focus on the current topic  

   
    #search for the ID in the prediction file
    filtered_df = tpreds[tpreds['docId'].str.contains(gtID, case=False, na=False)]
    
    hits=len(filtered_df) 
      
    if (hits != 1):
        print(f"Error, el fichero de predicciones contiene más de una fila (o ninguna) para algún identificador ({gtID} - {hits} hits)")
        break
      
    prediction_label = filtered_df.iloc[0]['correctness']

    if (gtlabel == 1):
        if (prediction_label == 1):
            tpos += 1
        else:
            fneg += 1
    else:
        if (prediction_label == 1):
            fpos += 1
        else:
            tneg += 1
            
    
    
print(f"True Positives: {tpos}, True Negatives: {tneg}, False Positives: {fpos}, False Negatives: {fneg}")  

acc = (tpos+tneg)/(tpos+tneg+fpos+fneg)

print(f"Accuracy: {acc}")  