import pandas as pd
import numpy as np

def comparar_csv(archivo1, archivo2):
    try:
        # Leer los archivos CSV
        df1 = pd.read_csv(archivo1)
        df2 = pd.read_csv(archivo2)
        
        # Verificar si tienen las mismas dimensiones
        if df1.shape != df2.shape:
            return f"Los archivos tienen diferentes dimensiones:\n{archivo1}: {df1.shape}\n{archivo2}: {df2.shape}"
        
        # Verificar si tienen las mismas columnas
        if set(df1.columns) != set(df2.columns):
            return f"Los archivos tienen diferentes columnas:\n{archivo1}: {list(df1.columns)}\n{archivo2}: {list(df2.columns)}"
        
        # Ordenar ambos DataFrames por todas las columnas
        df1_sorted = df1.sort_values(by=list(df1.columns)).reset_index(drop=True)
        df2_sorted = df2.sort_values(by=list(df2.columns)).reset_index(drop=True)
        
        # Comparar los DataFrames ordenados
        diferencias = []
        for columna in df1.columns:
            mask = df1_sorted[columna] != df2_sorted[columna]
            if mask.any():
                for idx in mask[mask].index:
                    diferencias.append(f"Fila {idx}, Columna '{columna}':\n"
                                    f"{archivo1}: {df1_sorted.loc[idx, columna]}\n"
                                    f"{archivo2}: {df2_sorted.loc[idx, columna]}")
        
        if diferencias:
            return "Diferencias encontradas:\n" + "\n\n".join(diferencias)
        else:
            return "todo okey maquina"
            
    except FileNotFoundError as e:
        return f"Error: No se encontró el archivo - {e}"
    except Exception as e:
        return f"Error inesperado: {e}"

if __name__ == "__main__":
    archivo1 = '/Users/luisi/Documents/Master-Big-Data/Bases de datos a gran escala/Practica/Resultados/csvs/q5_relacional.csv'
    archivo2 = '/Users/luisi/Documents/Master-Big-Data/Bases de datos a gran escala/Practica/Resultados/csvs/q5_neo4j.csv'
    
    resultado = comparar_csv(archivo1, archivo2)
    print(resultado)