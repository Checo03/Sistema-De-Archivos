#!/bin/bash

directorio=$1

main() {
    if [ ! -d "$directorio" ]; then
        zenity --error --text "El directorio $directorio no existe."
        exit 1
    else	
	while true; do
			lista=$(ls "$directorio") # Se llena una lista con el contenido dentro de los directorios
        
			listaDirectorios=()
			for dir in $lista; do #Alamcena los directorios Al arreglo
				listaDirectorios+=("$dir" "")
			done
			listaDirectorios+=("Menu_Opciones" "")
			
    		seleccion=$(dialog --clear --stdout --title "Directorios $directorio" \
                --menu "Directorios y archivos" 0 0 0 "${listaDirectorios[@]}")
                
    		if [ -n "$seleccion" ]; then #Comprueba que se seleccionara algo
			if [ "$seleccion" == "Menu_Opciones" ]; then 
					./menuOpciones.sh "$directorio"
			else
				direccion=$directorio"/"$seleccion # Guarda el nuevo directorio a Buscar
				if [ -d "$direccion" ]; then #Comprueba si el directorio es válido
					lista=$(ls "$direccion") #Ve el contenido que está dentro del Directorio Seleccionado
					if [ -z "$lista" ]; then #Checa si el subDirectorio está vacío
						zenity --info --text "Directorio Vacio"
					fi
					./mostrarSubDirectorio.sh "$direccion"
				else
					nano "$direccion"
				fi
			fi	
    		else
        		exit 0
    		fi
	done

    fi
}

main
