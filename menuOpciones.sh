#!/bin/bash

directorio=$1

crear_directorio () {
    directorio=$1
	nombre=""
	while [ -z "$nombre" ]; do
		nombre=$(dialog --clear --stdout --title "Crear directorio" \
				--inputbox "Ingresa el nombre del directorio:" 0 0)
	done
    if [ -n "$nombre" ]; then
    	if mkdir "$directorio/$nombre" >/dev/null 2>&1; then
      		zenity --info --text "Se ha creado el directorio: $nombre."
    	else
      		zenity --error --text "No se pudo crear el directorio."
    	fi
  	else
    	zenity --error --text "No se ingresó ningún nombre."
  	fi
}

crearArchivo() {
    directorio=$1
    nombre=""
    while [ -z "$nombre" ]; do
        nombre=$(dialog --clear --stdout --title "Crear archivo" \
                --inputbox "Ingresa el nombre del archivo:" 0 0)
    done

    if [ -n "$nombre" ]; then
        archivo="$directorio/$nombre"
        if touch "$archivo" >/dev/null 2>&1; then
            zenity --info --text "Se ha creado el archivo: $nombre."
        else
            zenity --error --text "No se pudo crear el archivo."
        fi
    else
        zenity --error --text "No se ingresó ningún nombre."
    fi
}

copiar () {
    directorio=$1
	directorio2=/
	lista=$(ls "$directorio") # Se llena una lista con el contenido dentro de los directorios
    lista2=$(ls "$directorio2")

	listaDirectorios=()
	for dir in $lista; do #Alamcena los directorios Al arreglo
		listaDirectorios+=("$dir" "")
	done
	listaDirectorios2=()
	for dir2 in $lista2; do #Alamcena los directorios Al arreglo
		listaDirectorios2+=("$dir2" "")
	done

    seleccion=$(dialog --clear --stdout --title "Seleccionar archivo" \
              --menu "Elige un elemento para copiar:" 0 0 0 "${listaDirectorios[@]}")
	origen="$directorio/$seleccion"
	seleccion2=$(dialog --clear --stdout --title "Seleccionar archivo" \
              --menu "Elige el destino:" 0 0 0 "${listaDirectorios2[@]}")
	destino="$directorio2/$seleccion2"
    #Comprueba que el archivo/directorio exista
    if [ -e "$origen" ]; then
        cp -r "$origen" "$destino"  #Copia el origen recursivamente con -r (lo cual es necesario para copiar directorios)
        zenity --info --text "Se ha copiado el elemento $seleccion."
    else
        zenity --error --text "El archivo/directorio de origen no existe."
    fi
}
borrar () {
	directorio=$1
	lista=$(ls "$directorio") # Se llena una lista con el contenido dentro de los directorios
        
	listaDirectorios=()
	for dir in $lista; do #Alamcena los directorios Al arreglo
		listaDirectorios+=("$dir" "")
	done

    seleccion=$(dialog --clear --stdout --title "Seleccionar archivo" \
              --menu "Elige un archivo para borrar:" 0 0 0 "${listaDirectorios[@]}")
	if [ -n "$seleccion" ]; then
		archivo="$directorio/$seleccion"
		if [ -e "$archivo" ]; then 	#Comprueba que el archivo/directorio exista
			if rm -r "$archivo" >/dev/null 2>&1; then  #Verifica y lo elimina
				zenity --info --text  "Elemento borrado: $archivo"
			else
				zenity --error --text "No se pudo borrar el elemento."
			fi
		else
			zenity --error --text "El elemento $archivo no existe."
		fi
	else
		zenity --error --text "No se seleccionó ningún elemento."
	fi
}
editar_archivo () {
    directorio=$1

	lista=$(ls "$directorio") # Se llena una lista con el contenido dentro de los directorios
        
	listaDirectorios=()
	for dir in $lista; do #Alamcena los directorios Al arreglo
		listaDirectorios+=("$dir" "")
	done
	seleccion=$(dialog --clear --stdout --title "Seleccionar archivo" \
              --menu "Elige un archivo para renombrar:" 0 0 0 "${listaDirectorios[@]}")
	archivo="$directorio/$seleccion"
    #Comprueba si es un archivo
    if [ -f "$archivo" ]; then
        nano "$archivo"
    else
        zenity --error --text "El archivo $archivo no existe."
    fi
}
renombrar () {
    directorio=$1

	lista=$(ls "$directorio") # Se llena una lista con el contenido dentro de los directorios
        
	listaDirectorios=()
	for dir in $lista; do #Alamcena los directorios Al arreglo
		listaDirectorios+=("$dir" "")
	done
	seleccion=$(dialog --clear --stdout --title "Seleccionar archivo" \
              --menu "Elige un archivo para renombrar:" 0 0 0 "${listaDirectorios[@]}")
	if [ -n "$seleccion" ]; then
    	archivo="$directorio/$seleccion"
    	if [ -e "$archivo" ]; then
      		if [ -w "$archivo" ]; then 	#Comprobar permisos de escritura de archivo
        		nuevo_nombre=$(dialog --clear --stdout --title "Renombrar" \
                      		--inputbox "Ingresa el nuevo nombre:" 0 0)
        		if [ -n "$nuevo_nombre" ]; then   #Comprobar si se ingresa algun nombre
          			nuevo_archivo="$directorio/$nuevo_nombre"
          			if mv "$archivo" "$nuevo_archivo" >/dev/null 2>&1; then
            			zenity --info --text "Elemento renombrado: $archivo -> $nuevo_archivo"
          			else
            			zenity --error --text "No se pudo renombrar el elemento."
          			fi
        		else
          			zenity --error --text "No se ingresó ningún nombre."
        		fi
      		else
        		zenity --error --text "No tienes permisos de escritura en el archivo seleccionado."
      		fi
    	else
      		zenity --error --text "El elemento $archivo no existe."
    	fi
  	else
    	zenity --error --text "No se seleccionó ningún elemento."
  	fi
}
comprimir () {
	#Se empaqueta y se comprime dentro de la misma funcion
	directorio=$1

	lista=$(ls "$directorio") # Se llena una lista con el contenido dentro de los directorios
        
	listaDirectorios=()
	for dir in $lista; do #Alamcena los directorios Al arreglo
		listaDirectorios+=("$dir" "")
	done
	seleccion=$(dialog --clear --stdout --title "Seleccionar archivo" \
              --menu "Elige un archivo para comprimir:" 0 0 0 "${listaDirectorios[@]}")
	origen="$directorio/$seleccion"
	destino=$(basename "$origen")  #Obtener el nombre puro del origen
    #Comprueba que el archivo/directorio exista
    if [ -e "$origen" ]; then
		#f: Empaqueta  z: Comprime  c: Crear archivo 
        tar -czvf "$destino.tgz" "$origen" #Se crea un archivo ".tgz" comprimido
		cp -r "$destino.tgz" "$directorio" #Una vez que se crea se copia dentro del directorio en el que se encuentra
        zenity --info --text "Se ha creado el archivo comprimido $destino.tar."
    else
        zenity --error --text "El archivo/directorio de origen no existe."
    fi
}
descomprimir () {
	#Se desempaqueta y se descomprime dentro de la misma funcion
	directorio=$1

	lista=$(ls "$directorio") # Se llena una lista con el contenido dentro de los directorios
        
	listaDirectorios=()
	for dir in $lista; do #Alamcena los directorios Al arreglo
		listaDirectorios+=("$dir" "")
	done
	archivo_comprimido=$(dialog --clear --stdout --title "Seleccionar archivo" \
              --menu "Elige un archivo para descomprimir:" 0 0 0 "${listaDirectorios[@]}")

    #Comprueba que el archivo/directorio comprimido exista
    if [ -e "$archivo_comprimido" ]; then
        #Desempaquetar y descomprimir el archivo(-C: Indica el directorio de destino donde se va a descomprimir)
        tar -xzvf "$archivo_comprimido" -C "$directorio" 
        zenity --info --text "Se ha descomprimido el archivo $archivo_comprimido."
    else
        zenity --error --text "El archivo comprimido $archivo_comprimido no existe."
    fi
}
Buscar_archivos () {
	directorio=/
	nombre=$(zenity --entry --title "Buscar archivo" --text "Ingresa el nombre del archivo:")

	if [ -n "$nombre" ]; then
    		resultados=$(find "$directorio" -type f -name "$nombre" -print0)

    		if [ -n "$resultados" ]; then
        		zenity --info --title "Resultados de búsqueda" --text "Archivos encontrados:\n\n$resultados"
    		else
        		zenity --error --text "No se encontró ningún archivo."
    		fi
	else
    		zenity --error --text "No se ingresó ningún nombre de archivo."
	fi
}

permisosArchivos() { 
	directorio=$1 
	lista=$(ls "$directorio") # Se llena una lista con el contenido dentro de los directorios
	listaDirectorios=() 
	for dir in $lista; do #Alamcena los directorios Al arreglo 
		listaDirectorios+=("$dir" "") 
	done 
	seleccion=$(dialog --clear --stdout --title "Seleccionar archivo" --menu "Elige un archivo para mostrar permisos:" 0 0 0 "${listaDirectorios[@]}")

	archivo="$directorio/$seleccion" 
	if [ -f "$archivo" ]; then 
		permisos=$(ls -l "$archivo" | awk '{print $1}') 
		zenity --info --text "Permisos de $archivo: $permisos" 
	else 
		zenity --error --text "El archivo $archivo no existe." 
	fi 
}



main(){
	mostrarOpciones=()
	mostrarOpciones+=("Crear_Directorio" "")
	mostrarOpciones+=("Crear_Archivo" "")
	mostrarOpciones+=("Copiar" "")
	mostrarOpciones+=("Eliminar" "")
	mostrarOpciones+=("Editar_Archivo" "")
	mostrarOpciones+=("Renombrar" "")
	mostrarOpciones+=("Comprimir" "")
	mostrarOpciones+=("Descomprimir" "")
	mostrarOpciones+=("Buscar_archivos" "")
	mostrarOpciones+=("Permisos_archivos" "")
	mostrarOpciones+=("Salir" "")
	
	while true; do
        seleccion=$(dialog --clear --stdout --title "Menu $directorio" \
                    --menu "Opciones" 0 0 0 "${mostrarOpciones[@]}")

        case "$seleccion" in
            $'Crear_Directorio')
                crear_directorio "$directorio"
                ;;
            $'Crear_Archivo')
                crearArchivo "$directorio"
                ;;
            $'Copiar')
                copiar "$directorio"
                ;;
            $'Eliminar')
                borrar "$directorio"
                ;;
            $'Editar_Archivo')
                editar_archivo "$directorio"
                ;;
            $'Renombrar')
                renombrar "$directorio"
                ;;
            $'Comprimir')
                comprimir "$directorio"
                ;;
            $'Descomprimir')
                descomprimir "$directorio"
                ;;
            $'Buscar_archivos')
                Buscar_archivos 
                ;;
            $'Permisos_archivos')
                permisosArchivos "$directorio" 
                ;;
            *)
                exit 0
                ;;
        esac

    done
}

main


