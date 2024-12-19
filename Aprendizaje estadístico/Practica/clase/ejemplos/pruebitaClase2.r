# Realidad: mu=2
# generar datos bajo esa realidad
datos <- rnorm(100, mean=2, sd=3) # mu=2, sigma=3
hist(datos)

# que pasa si no conozco mu?

# estimador puntual: media muestral
mean(datos)

# ¿donde esta la media real con una prob del 95%?
t.test(datos)



# generar 1000 muestras de tamaño 100
meanvec <- numeric() # vector de medias vacio 
for (i in 1:1000) {
  datos <- rnorm(100, mean=2, sd=3)
  meanvec[i] <- mean(datos)
}

hist(meanvec)

datos <- rexp(1000) # exponencial 
hist(datos)

medias <- numeric()
for (i in 1:1000) {
  datos <- rexp(1000)
  medias[i] <- mean(datos)
}

hist(medias) # aqui vemos el teorema del limite central
boxplot(medias)
plot(density((datos)))


# numero de veces que la media real (2) esta dentro del intervalo de confianza al 95%

# almacenamos los trues
dentrovec <- numeric()

for (i in 1:1000) {
  datos <- rnorm(100, mean=2, sd=3)
  ic <- t.test(datos)$conf.int # esta la media entre los extremos ?
  dentrovec[i] <- (ic[1] < 2) & (ic[2] > 2) # si es true es que la media (2) esta dentro del intervalo
}

table(dentrovec)/length(dentrovec) # 95% de las veces la media real estara dentro del intervalo

t.test(datos, mu=2)$p.value # pvalor
