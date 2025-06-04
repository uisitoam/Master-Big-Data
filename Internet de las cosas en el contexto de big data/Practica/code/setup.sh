# Crear cuenta en particle.io

particle setup
# o en nuevas versiones quizás es: ?
particle tachyon setup ????

# Descargar firmware de https://github.com/particle-iot/esp32-ncp-firmware/releases/tag/v0.0.5

# Conectar antena WiFi a U.FL
# Conectar el Argon por USB al ordenador, COMPROBAR QUE PARPADEA AZUL

# Poner Argon en modo DFU (parpadeo AMARILLO):
    # Mantener pulsado MODE/SETUP
    # Pulsar RESET manteniendo MODE. Pasará a brillar MAGENTA y después de unos segundos
    # pasará a parpadear AMARILLO.
    # Soltar el botón MODE

    # Una vez hayamos flasheao el device (aún no lo está aquí), podemos volver a ponerlo
    # en modo DFU con el comando:
    # | particle usb dfu |

# Una vez en modo DFU, actualizar el dispositivo:
particle update

particle usb dfu # volver a DFU solo si el dispositivo salio del modo DFU / ya no está AMARILLO

particle flash --usb tinker

# Flasehar ahora el firmware de verdad, para esto el led debe estar parpadeando AZUL OSCURO / Listening mode
# Si no esta en AZUL OSCURO, para entrar en modo LISTENING deberemos pulsar MODE/SETUP por unos segundos

# Una vez en LISTENING y no en DFU (AMARILLO MALO):
particle flash --serial argon-ncp-firmware-0.0.5-ota.bin

# Verificar que todo fue bien, en LISTENING MODE:
particle serial identify

# Salida esperada
# Your device id is <e00fce68545502254fc627e0>
# Your system firmware version is 1.5.0

# Anotar el device id: e00fce68545502254fc627e0

# Ajustar WiFi en el Argon, para ello debe estar en modo LISTENING
particle serial wifi

# Logearse en la cuenta de particle.io
particle login

# Despues de flashear y ajustar el Argon, deberia seguir la secuencia:
# PARPADEO VERDE => PARPADEO CIAN => RAPIDO PARPADEO CIAN => RESPIRACION CYAN

# Una vez que esté en RESPIRACION CIAN, registrar el dispositivo en nuestra cuenta:
particle device add <CAMBIAR_AQUI_EL_DEVICE_ID>

# Renombrar el dispositivo a argon-X, siendo X el grupo
particle device rename <CAMBIAR_AQUI_EL_DEVICE_ID> argon-<cambiar_aqui_grupo>

# Fijar el dispositivo como completado el setup
particle usb setup-done
