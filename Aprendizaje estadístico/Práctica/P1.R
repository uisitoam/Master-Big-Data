3*3
3-3
3**3
3^3
elem<-6
elem
elem=6
elem
# Raíz cuadrada
sqrt(4)
Elem
# Ayuda de función
?sqrt
help(sqrt)

# Instalar paquetes
install.packages("moments")
# Cargar librería
library(moments)

# Eliminar un elemento
rm(elem)
elem

# Vectores
vect<-c(3,4,2,1)
c(vect,vect)
vect[2]
vect[c(2,3)]
# Secuencia de valores 
2:4
vect[2:4]
# Todos los elementos menos el primero
vect[-1]
#  Secuencia de valores
seq(1,5,by=2)
seq(1,5,length.out=3)

# Cargar datos
setwd("C:/Users/jose.ameijeiras/Downloads")
Advertising <- read.csv("Advertising.csv")
head(Advertising)

# Crear matriz a mano
mat<-matrix(1:16,nrow=4,ncol=4)
mat
mat2<-matrix(1:4,nrow=2,ncol=2,byrow=T)
mat2

mat[2,4]
mat[c(2,3),4]
mat[2:3,3:4]

dim(mat)
class(mat)

# Bucles
suma<-0
for(i in 1:10){
  suma<-suma+i
  print(suma)
}
suma

suma<-0
while(suma<=30){
  suma<-suma+5
}
suma

suma<-30
if(suma==30){
  suma<-suma+5
}
suma

fun1<-function(x,y=3){
  x2<-x+2-y
  return(x2)
}
fun1(y=2,x=5)
fun1(2,5)

class(Advertising)
Advertising[1,2]
Advertising$TV[2]
Advertising$Sales[2]

# Unir vectores
cbind(1:3,4:6)
rbind(1:3,4:6)

mat[,4]

# Acceder solo a primera fila
Advertising[1,]

# Operaciones elemento a elemento
3*mat
mat*mat
mat+3
# producto matricial
mat%*%mat

1:3*1:4

dim(mat)
vect
length(vect)

install.packages("openintro")
library(openintro)
data(email)
head(email)
?email
email$spam
email$num_char

sum(email$num_char)/length(email$num_char)
mean(email$num_char)
median(email$num_char)
quantile(email$num_char)
min(email$num_char)
max(email$num_char)
summary(email$num_char)

# Varianza
var(email$num_char)
# Desviación típica
sd(email$num_char)

# Número de car, solo para email spam
mean(email$num_char[email$spam==1])
# Número de car, solo para email sin spam
mean(email$num_char[email$spam==0])

# Asimetría y curtosis
library(moments)
skewness(email$num_char)
kurtosis(email$num_char)

# Visualizar datos

# Gráfico de barras
barplot(email$num_char)

# Histograma
hist(email$num_char,breaks=50)
# Diagrama de caja
boxplot(email$num_char)

data("iris")
boxplot(iris$Petal.Length)

# Tabla de frecuencias (absolutas)
table(email$spam)
# Tabla de frecuencias (relativas)
table(email$spam)/length(email$spam)

# Gráfico de barras
barplot(table(email$spam))
# Gráfico de sectores
pie(table(email$spam))
