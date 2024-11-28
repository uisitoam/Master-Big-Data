# H0: mu = 5
# H1: mu != 5
# (quiero demostrar que es distinto de 5)
# Nivel de signif alfa = 0.05, es decir, voy a decir que es distino de 5 un 5% de las veces

t.test(email$num_char, mu=5)

# p-value < 2.2e-16 

# siempre que el pvalor es menor que alfa, demostramos lo que queriamos (rechazo la hipotesis nula H0), que el nivel medio de caracteres es distinto de 5