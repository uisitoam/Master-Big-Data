El objetivo de este trabajo es desarrollar el esquema inicial de un proyecto de inteligencia de negocio. Se abarcarán únicamente las fases de análisis de negocio, modelado de indicadores y diseño de los almacenes de datos para calcular los indicadores. Entregar un único archivo PDF

# 1. Introducción 

En este apartado se debe describir de manera global el negocio. Puede ser real o ficticio, y puede ser de cualquier ámbito, por ejemplo, salud, industria, política, deporte, educación, etc. Se puede utilizar la experiencia propia o estar basado en la realidad, en algún tema de interés del alumno.

El negocio se debe descomponer en diferentes áreas de negocio, que constituyan la empresa y que permitan dar una amplitud horizontal al trabajo. De manera orientativa, habría que intentar abarcar 3 áreas de negocio con la intención de que se establezcan diversos indicadores en el siguiente apartado calculados sobre diferentes hechos, y por tanto el modelado multidimensional que se hará tenga suficiente riqueza para poder usar varias técnicas de diseño y tipos de cubo. Por ejemplo, tres áreas básicas de una empresa podrían ser comercial, producción y gestión de clientes.

El tamaño del negocio debe estar pensado en escalar, es decir, si se piensa en una panadería, debe tener un alcance que no se limite a una sola tienda, ni a un sólo proceso, ni a un único tipo de producto, ni a un único tipo de empleado, etc.

Hay que documentar y referenciar las fuentes de datos utilizadas, o los ejemplos que puedan servir de inspiración u orientación, o que puedan aportar información tanto al alumno como al profesor para entender bien el negocio.

Se recomienda una descripción comprensible de aproximadamente 1 página.

# 2. Objetivos de negocio

En este apartado se debe descomponer la estrategia de cada una de las áreas de empresa identificada en factores críticos de éxito (CSF), y los indicadores (PI) necesarios para medir el cumplimiento de esos factores. Se debe incluir, para cada área de negocio identificada en el apartado anterior:
* Al menos un **Factor Crítico de Éxito (CSF)**. Una descripción de un párrafo es suficiente para entender cada uno.
* Para cada **CSF**, al menos un **Indicador de Desempeño (PI)**. Se recomienda tener varios (de manera orientativa 3) PIs por cada CSF.

Cuánto más conocimiento tenga el alumno sobre el negocio concreto, más sencillo será obtener CSF y PI. De manera global, se espera al menos un número de 10 PIs centrados en diversas áreas de negocio.

Al final de esta sección hay que incluir una tabla de la síntesis con el siguiente contenido:

| Factor Crítico de Éxito (CSF) | Identificador del indicador | Indicador | Tipo de indicador (*leading* o *lagging*) | Meta | Acción |
|----------|----------|----------|----------|----------|----------|
| ... | ... | ... | ... | ... | ... |
| ... | ... | ... | ... | ... | ... |
| ... | ... | ... | ... | ... | ... |


# 3. Diseño lógico

Este apartado consiste en el diseño de los almacenes de datos que permitan medir los PI diseñados en el apartado anterior para seguir la estrategia de empresa.

## 3.1. Procesos de negocio

El primer paso es identificar los procesos de negocio asociados a los indicadores, y describir el hecho que representa. En la sección 3.3 se describirá de manera explícita cómo calcular cada indicador a partir del hecho.

De manera general, deberá haber al menos 3 procesos de negocio. En caso de obtener más, será suficiente con describir los 3 principales para el negocio y que aporten al total el mayor número de dimensiones. Esto habrá que confirmarlo con el profesor para asegurar la calidad del trabajo.

Para cada proceso de negocio, que será un hecho, se establecerá:

* **Descripción**
* **Granularidad**
* **Tasa de refresco**
* **Tipo de tabla de hecho**
* **Medidas**. Para cada medida hay que indicar una descripción, el tipo de medida, y la forma de obtenerla.

Se incluirá un diagrama individual para cada proceso (con cualquier herramienta) donde se vean las medidas y las dimensiones. 

Se recomienda hacer un único diagrama donde se muestren todos los procesos y las dimensiones (incluyendo solo los nombres en ambos casos, no el listado de atributos) para tener una panorámica global.

## 3.2. Dimensiones

Para cada dimensión se indicará:

* **Descripción**
* **Si es una dimensión compartida entre varios hechos**, se indicará qué hechos la comparten.
* **Atributos** con nombre, tipo de datos y descripción.
* **Si es lentamente cambiante**, se indicará la forma de abordarlo.
* **Técnicas de diseño de dimensiones** utilizadas, si corresponde.

En caso de haber una o más jerarquías de atributos, habrá que indicar los niveles. En caso de tener muchas dimensiones, habrá que centrar la descripción en las dimensiones más ricas y de interés desde el punto de vista de modelado. Esto habrá que confirmarlo con el profesor para asegurar la calidad del trabajo.

## 3.3. Cálculo de los indicadores a partir del diseño lógico

Este apartado consiste en una descripción (sin código SQL) de cómo se calcula cada indicador del apartado 2. Se incluirá una tabla donde se especifique:

| Identificador del indicador | Indicador | Proceso de negocio | Descripción del cálculo |
|----------|----------|----------|----------|
| ... | ... | ... | ... |
| ... | ... | ... | ... |
| ... | ... | ... | ... |