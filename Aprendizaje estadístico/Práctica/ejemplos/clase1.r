# library(moments)
# VECTORES
# vect <- c(3, 4, 2) # se crean 
# length(vect) # longi del vector 
# vect[1] es 3
# vect[-1] llama a todos menos el primero
# vect[c(2,3)] para llamar a 4, 2
# 2:3 # dos puntos crea secuencia de uno en uno (intervalo cerrado)
#seq(1, 5, by=2) # secuencia con paso definido
# seq(1, 5, le=3) # secuencia con longitud definida

# cbind(vec1, vec2) # pega vectores por columnas
# rbind(vec1, vec2) # pega vectores por filas

Advertising <- read.csv("Advertising.csv", dec=".")
head(Advertising)

# MATRICES 
mat <- matrix(1:16, nrow=4, ncol=4) # R rellena hacia abajo (por columnas)
mat[2:3, 4] # no poner nada es como poner el : en python mat[,4]
dim(mat) # dimension de la matriz
class(mat) # ver la clase 
# data.frame se lee como una matriz
Advertising[1,2]
Advertising$TV # accede a la columna 
Advertising[1,] # accede a la primera columna

 # BUCLES
suma <- 0
for (i in 1:10){
    suma <- suma + i
}