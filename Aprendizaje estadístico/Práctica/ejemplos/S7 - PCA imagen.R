# Leemos la imagen
library(magick)
imag <- image_read('lange.jpg')

# La pasamos a blanco y negro
imag2 <- imag %>% image_quantize(colorspace = 'gray')
# Convertimos la información a una matriz
matima <- imag2[[1]]
dimima <- dim(matima)[2:3]
matima <- (matima[1,,])
matima <- matrix(as.double(matima),nrow=dimima[2])
matima <- matima[,dimima[1]:1]
# Vemos cómo era la imagen original
image(matima,col = hcl.colors(12, "Gray", rev = F))

# Aplicamos componentes principales
pca <- princomp(t(matima))

# Variabilidad explicada (Autovalores)
av <- pca$sdev^2
cumsum(av)/sum(av)

# Si nos quedamos con las primeras 25
ncomp <- 25
newimage <- pca$loadings[,1:ncomp]%*%t(pca$scores)[1:ncomp,]
newimage <- newimage+ pca$center
image(newimage,col = hcl.colors(12, "Gray", rev = F))
