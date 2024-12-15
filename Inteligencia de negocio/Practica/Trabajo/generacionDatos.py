def calculo(nombre, gastos, persona, personas, domi):
    """
    Calcula los ingresos y gastos de un restaurante. Los aprametros son listas con un valor minimo, medio y maximo para
    cada atributo variable, y un valor fijo para gastos fijos.

    :param nombre: nombre del restaurante
    :param gastos: lista con los gastos fijos, variables, y de personal y proveedores
    :param persona: lista con el número de personas que visitan el restaurante
    :param personas: lista con los precios de los platos
    :param domi: lista con los ingresos de domicilio

    :return: listas con los ingresos y gastos mensuales
    """
    print(nombre)
    ingresos = [persona[i] * personas[i] for i in range(len(personas))]
    print(f"Ingresos/días {ingresos}")
    mes = [ig*26 for ig in ingresos]
    print(f"Ingresos/mes {mes}")
    porc = [0.15, 0.3]
    gasto = [gastos[0] + gastos[1] + gastos[2][i] + gastos[3][i] for i in range(len(persona))]
    print(f"Domicilio/mes: {[domi[i] * (1-porc[i]) for i in range(len(domi))]}")
    print(f"Gastos/mes {gasto}")
    print(f"Gastos dom/mes {[domi[i] * porc[i] for i in range(len(domi))]}")
    print(f"Margen de beneficio: {100 * (1 - (gasto[1] / mes[1]))}%")
    print()
    return mes, gasto

santiago = calculo("Santiago", [2200, 12950, [4500, 5000, 5500], [1100, 1150, 1300]], 
                   [50, 70, 80], [12, 14, 18], [2500, 3000])

vigo = calculo("Vigo", [1650, 12000, [4300, 4600, 4900], [1000, 1100, 1150]], 
               [50, 60, 70], [11, 13, 16], [1500, 2000])

granada = calculo("Granada", [2300, 13250, [4500, 4800, 5200], [1100, 1150, 1300]], 
                  [60, 76, 90], [12, 15, 20], [2500, 3000])

sevilla = calculo("Sevilla", [3500, 15500, [5000, 5300, 5600], [1200, 1350, 1500]], 
                  [70, 80, 100], [13, 16, 20], [2500, 3000])

valencia = calculo("Valencia", [3250, 15500, [5200, 5500, 6000], [1200, 1300, 1400]], 
                   [70, 90, 110], [13, 16, 20], [2500, 3000])

alicante = calculo("Alicante", [1700, 12500, [4200, 4400, 4500], [1000, 1100, 1300]], 
                   [50, 65, 75], [13, 14, 18], [1750, 2000])

ll = calculo("LL", [1300, 12000, [3000, 3250, 3600], [1000, 1050, 1200]], 
             [50, 60, 70], [10, 14, 18], [1500, 2000])

lpgc = calculo("LPGC", [1650, 12250, [3000, 3250, 3600], [1100, 1150, 1250]], 
               [50, 65, 70], [10, 14, 18], [1500, 2000])

hermigua = calculo("Hermigua", [600, 8000, [1750, 2000, 2500], [800, 950, 1000]], 
                   [30, 45, 55], [8, 11, 15], [1000, 1250])

tazacorte = calculo("Tazacorte", [800, 10000, [2000, 2100, 2400], [900, 1000, 1100]], 
                    [40, 50, 65], [9, 12, 16], [1250, 1500])

valverde = calculo("Valverde", [650, 7000, [1400, 1500, 1700], [800, 900, 950]], 
                   [30, 40, 45], [8, 10, 14], [900, 1100])

cotillo = calculo("Cotillo", [1000, 10500, [2000, 2200, 2500], [850, 950, 1000]], 
                  [45, 60, 75], [10, 14, 17], [1300, 1500])

arrecife = calculo("Arrecife", [1000, 10500, [2000, 2100, 2300], [800, 900, 1100]], 
                   [45, 55, 65], [10, 14, 17], [1300, 1500])




# productos y precios 
mapa_canario = {1:["Almogrote Gomero", 5], 2:["Papas arrugadas con mojo", 6.5], 
                3:["Queso asado con mojo", 7], 4:["Escaldon", 7], 
                5:["Ropa vieja", 9], 6:["Costilla con papas y pina", 10], 
                7:["Carne fiesta", 9.5], 8:["Quesillo", 4.5], 
                9: ["Bienmesabe", 4.5], 10:["Arepa reina pepiada", 4],
                11:["Arepa pabellon", 4], 12:["Arepa full equipo", 4],
                13:["Arepa vegana", 4], 14:["Arepa blanca", 4],
                15:["Vino tinto canario", 5], 16:["Vino blanco canario", 5], 
                17:["Agua", 1.5], 18:["Cola", 2], 
                19:["Limon", 2], 20:["Naranja", 2], 
                21:["Aquarius", 2], 22:["Nestea mangopina", 2]}

mapa_santiago = {23:["Pulpo a feira", 13], 24:["Empanada", 4], 
                 25:["Lacon con grelos", 13], 26:["Tarta de Santiago", 4.5],
                 27:["Vino tintos gallego", 5], 28:["Vino blanco gallego", 5]}
mapa_santiago.update(mapa_canario)

mapa_andalucia = {29:["Salmorejo", 6], 30:["Pescaito frito", 10.5],
                  31:["Gambitas de huelva", 12], 32:["Pestinos", 4.5],
                  33:["Vino tinto andaluz", 5], 34:["Vino blanco andaluz", 5]}
mapa_andalucia.update(mapa_canario)

mapa_valencia = {35:["Paella", 12], 36:["Arroz negro", 12],
                    37:["Esgarraet", 6.5], 38:["Fartons", 4.5],
                    39:["Vino tinto valenciano", 5], 40:["Vino blanco valenciano", 5]}
mapa_valencia.update(mapa_canario)



import os
import random
from datetime import datetime
import numpy as np
import xml.etree.ElementTree as ET

def generar_valor_normal(minimo, medio, maximo):
    sigma = (maximo - minimo) / 6  # asumimos 99.7% de datos en +- 3 sigma
    valor = np.random.normal(medio, sigma)
    while valor < minimo or valor > maximo:
        valor = np.random.normal(medio, sigma)
    return valor

def generar_valor_uniforme(minimo, medio, maximo):
    valor = np.random.uniform(minimo, maximo)
    return int(round(valor))

def generar_ventas_platos(platos_info, total_ingresos):
    precios = {id_plato: info[1] for id_plato, info in platos_info.items()}
    ids_platos = list(platos_info.keys())
    num_platos = len(ids_platos)
    
    # generamos pesos aleatorios
    weights = np.random.rand(num_platos)
    weights /= weights.sum()
    
    # calculamos ventas para cada plato
    ventas = {}
    for i, id_plato in enumerate(ids_platos):
        precio = precios[id_plato]
        ingreso_asignado = total_ingresos * weights[i]
        venta = ingreso_asignado / precio
        ventas[id_plato] = int(round(venta))
    
    # ajustamos ventas para que no sean negativas
    ventas = {k: max(0, v) for k, v in ventas.items()}
    
    # recalculamos total ingresos asignados
    total_ingresos_asignado = sum(ventas[id_plato] * precios[id_plato] for id_plato in ventas)
    
    # ajustamos ventas para igualar total_ingresos
    diferencia = total_ingresos - total_ingresos_asignado
    precios_ordenados = sorted(precios.items(), key=lambda x: x[1])
    index = 0
    while abs(diferencia) >= min(precios.values()):
        id_plato = precios_ordenados[index % num_platos][0]
        precio_plato = precios[id_plato]
        if diferencia > 0:
            ventas[id_plato] += 1
            diferencia -= precio_plato
        elif ventas[id_plato] > 0:
            ventas[id_plato] -= 1
            diferencia += precio_plato
        index += 1
        if index > num_platos * 10:
            break 
    return ventas

def generar_archivos(id, alquiler, personal, proveedores_params, coste_extra_params, ingresos_presencial_params, ingresos_domicilio_params, num_clientes_presencial_params, nuevos_clientes_presencial_params, num_clientes_domicilio_params, nuevos_clientes_domicilio_params, platos_info):
    if not os.path.exists('finanzas'):
        os.makedirs('finanzas')
    fechas = []
    start_date = datetime(2021, 2, 1)
    for i in range(36):
        month = (start_date.month + i - 1) % 12 + 1
        year = start_date.year + (start_date.month + i - 1) // 12
        date = datetime(year, month, 1)
        fechas.append(date.strftime('%Y-%m-%d'))
    for fecha in fechas:
        datos = ET.Element('datos')
        finanzas = ET.SubElement(datos, 'finanzas', id=id, emision=fecha)
        ET.SubElement(finanzas, 'alquiler').text = f'{alquiler:.2f}'
        ET.SubElement(finanzas, 'personal').text = f'{personal:.2f}'
        proveedores = generar_valor_normal(*proveedores_params)
        ET.SubElement(finanzas, 'proveedores').text = f'{proveedores:.2f}'
        extra = generar_valor_normal(*coste_extra_params)
        ET.SubElement(finanzas, 'extra').text = f'{extra:.2f}'
        ingresos_presencial = generar_valor_normal(*ingresos_presencial_params)
        ET.SubElement(finanzas, 'ingresos_presencial').text = f'{ingresos_presencial:.2f}'
        ingresos_domicilio = generar_valor_normal(*ingresos_domicilio_params)
        ET.SubElement(finanzas, 'ingresos_domicilio').text = f'{ingresos_domicilio:.2f}'
        total_ingresos = ingresos_presencial + ingresos_domicilio
        num_clientes_presencial = generar_valor_uniforme(*num_clientes_presencial_params)
        ET.SubElement(finanzas, 'numero_clientes_presencial').text = str(num_clientes_presencial)
        nuevos_clientes_presencial = generar_valor_uniforme(*nuevos_clientes_presencial_params)
        ET.SubElement(finanzas, 'nuevos_clientes_presencial').text = str(nuevos_clientes_presencial)
        num_clientes_domicilio = generar_valor_uniforme(*num_clientes_domicilio_params)
        ET.SubElement(finanzas, 'numero_clientes_domicilio').text = str(num_clientes_domicilio)
        nuevos_clientes_domicilio = generar_valor_uniforme(*nuevos_clientes_domicilio_params)
        ET.SubElement(finanzas, 'nuevos_clientes_domicilio').text = str(nuevos_clientes_domicilio)
        platos_element = ET.SubElement(finanzas, 'platos')
        ventas_platos = generar_ventas_platos(platos_info, total_ingresos)
        for id_plato, (nombre, precio) in platos_info.items():
            ventas = ventas_platos.get(id_plato, 0)
            ET.SubElement(platos_element, 'plato', id=str(id_plato),
                          nombre=nombre,
                          precio=f'{precio:.2f}',
                          ventas=str(ventas))
        filename = f"finanzas/{finanzas.attrib['id']}_{fecha}.xml"
        tree = ET.ElementTree(datos)
        tree.write(filename, encoding='utf-8', xml_declaration=True)





generar_archivos("1", 1300, 12000, [3000, 3250, 3600], [1000, 1050, 1200], ll[0], [1500, 1700, 1800], 
                 [50*26, 60*26, 70*26], [90, 120, 150], [160, 290, 380], [30, 90, 130], mapa_canario)

generar_archivos("4", 1650, 12250, [3000, 3250, 3600], [1100, 1150, 1250], lpgc[0], [1300, 1700, 2000], 
                 [50*26, 65*26, 70*26], [90, 120, 160], [170, 300, 390], [30, 100, 140], mapa_canario)

generar_archivos("5", 800, 10000, [2000, 2100, 2400], [900, 1000, 1100], tazacorte[0], [950, 1100, 1300], 
                 [40*26, 50*26, 65*26], [40, 55, 70], [70, 80, 100], [15, 25, 40], mapa_canario)

generar_archivos("6", 650, 7000, [1400, 1500, 1700], [800, 900, 950], valverde[0], [400, 650, 800], 
                 [30*26, 40*26, 45*26], [20, 25, 40], [40, 60, 70], [5, 14, 23], mapa_canario)

generar_archivos("2", 600, 8000, [1750, 2000, 2500], [800, 950, 1000], hermigua[0], [500, 700, 850], 
                 [30*26, 45*26, 55*26], [30, 40, 60], [50, 90, 120], [10, 20, 35], mapa_canario)

generar_archivos("3", 1000, 10500, [2000, 2200, 2500], [850, 950, 1000], cotillo[0], [800, 1100, 1250], 
                 [45*26, 60*26, 75*26], [40, 60, 80], [80, 100, 150], [25, 30, 40], mapa_canario)

generar_archivos("7", 1000, 10500, [2000, 2100, 2300], [800, 900, 1100], arrecife[0], [800, 1150, 1200], 
                 [45*26, 55*26, 65*26], [35, 55, 75], [70, 105, 140], [23, 33, 40], mapa_canario)

generar_archivos("8", 2300, 13250, [4500, 4800, 5200], [1100, 1150, 1300], granada[0], [2800, 3200, 3500], 
                 [60*26, 76*26, 90*26], [310, 410, 600], [280, 410, 600], [150, 280, 400], mapa_andalucia)

generar_archivos("10", 2200, 12950, [4500, 5000, 5500], [1100, 1150, 1300], santiago[0], [2500, 2700, 3000], 
                 [50*26, 70*26, 80*26], [300, 400, 520], [270, 400, 590], [140, 275, 390], mapa_santiago)

generar_archivos("11", 1650, 12000, [4300, 4600, 4900], [1000, 1100, 1150], vigo[0], [1800, 2000, 2250], 
                 [50*26, 60*26, 70*26], [150, 185, 215], [200, 280, 320], [80, 85, 100], mapa_santiago)

generar_archivos("12", 1700, 12500, [4200, 4400, 4500], [1000, 1100, 1300], alicante[0], [1900, 2100, 2300], 
                 [50*26, 65*26, 75*26], [160, 185, 230], [210, 300, 330], [90, 100, 110], mapa_valencia)

generar_archivos("9", 3500, 15500, [5000, 5300, 5600], [1200, 1350, 1500], sevilla[0], [2500, 2800, 3000], 
                 [70*26, 80*26, 100*26], [340, 435, 650], [260, 390, 580], [130, 260, 390], mapa_andalucia)

generar_archivos("13", 3250, 15500, [5200, 5500, 6000], [1200, 1300, 1400], valencia[0], [2600, 2900, 3150], 
                 [70*26, 90*26, 110*26], [350, 440, 660], [280, 410, 600], [150, 275, 400], mapa_valencia)






import pandas as pd
import numpy as np
import os
from datetime import datetime

def generar_valoraciones_csv(id_restaurante, clientes, cliente_dom):
    if not os.path.exists('datos'):
        os.makedirs('datos')

    inicio = datetime(2021, 2, 1)
    fin = datetime(2024, 2, 1)
    fecha_actual = inicio

    while fecha_actual < fin:
        año = fecha_actual.year
        mes = fecha_actual.month
        fecha_str = fecha_actual.strftime('%Y-%m-%d')
        filename = f"datos/{id_restaurante}_{fecha_str}.csv"

        # obtenemos el número de días del mes
        if mes == 12:
            siguiente_mes = datetime(año + 1, 1, 1)
        else:
            siguiente_mes = datetime(año, mes + 1, 1)
        dias_en_mes = (siguiente_mes - fecha_actual).days

        # Generamos las fechas con 6 días seguidos, 1 día de descanso
        dias = []
        dia = 1
        while dia <= dias_en_mes:
            for _ in range(6):
                if dia > dias_en_mes:
                    break
                dias.append(datetime(año, mes, dia))
                dia += 1
            dia += 1  # Saltar un día

        data = []

        total_dias = len(dias)
        # distribuimos valoraciones presenciales
        valoraciones_presencial_por_dia = clientes // total_dias
        extras_presencial = clientes % total_dias

        for i, fecha in enumerate(dias):
            fecha_formato = fecha.strftime('%Y-%m-%d')

            # valoraciones presenciales para el día
            num_valoraciones_presencial = valoraciones_presencial_por_dia + (1 if i < extras_presencial else 0)
            for _ in range(num_valoraciones_presencial):
                # generamos valoración presencial
                valoracion_ambiente = np.random.normal(4.1, 0.5)
                valoracion_ambiente = min(max(0.0, valoracion_ambiente), 5.0)
                valoracion_personal = np.random.normal(4.1, 0.5)
                valoracion_personal = min(max(0.0, valoracion_personal), 5.0)
                valoracion_comida = np.random.normal(4.1, 0.5)
                valoracion_comida = min(max(0.0, valoracion_comida), 5.0)
                fila = {
                    'restaurante': id_restaurante,
                    'fecha': fecha_formato,
                    'valoracion_ambiente': round(valoracion_ambiente, 1),
                    'valoracion_personal': round(valoracion_personal, 1),
                    'valoracion_comida': round(valoracion_comida, 1)
                }
                data.append(fila)

        df = pd.DataFrame(data)
        df.to_csv(filename, index=False)

        if mes == 12:
            fecha_actual = fecha_actual.replace(year=año + 1, month=1)
        else:
            fecha_actual = fecha_actual.replace(month=mes + 1)





min_clientes_1 = [50, 30, 45, 50, 40, 30, 45, 60, 70, 50, 50, 50, 70] # diario
min_clientes = [idx * 26 for idx in min_clientes_1] # mensual
min_clientes_dom = [160, 50, 80, 170, 70, 40, 70, 280, 260, 270, 200, 210, 280]

for i in range(len(min_clientes)):
    generar_valoraciones_csv(str(i+1), min_clientes[i], min_clientes_dom[i])

