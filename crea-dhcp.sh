#!/bin/sh
# Parseo de los Archivos
#########################################
############## FORMAT #####################
#########################################
# Nombre de todas las bibliotecas ordenadas 
# Numero de Equipos rojos  NER 
# Mac 1
#
#
# Mac N	
# Numero de Equipos Prestamo  NEP 
# Mac 1
#
#
# Mac N


#bloque para la generación completa
rm salida.dhcp															#Borra el archivo anterior 
max=256
dig4=0
dig3=34
echo "ddns-update-style none;" >> salida.dhcp
echo "option domain-name \"example.org\";" >> salida.dhcp
echo "log-facility local7;" >> salida.dhcp
echo "authoritative;" >> salida.dhcp
echo "			" >> salida.dhcp


## generacion del primer bloque 
echo "Introduce la subnet"
read var_snet 
echo "introduce la mascara y el rango"
read var_masq
echo "subnet $var_snet netmask $var_masq {" >> salida.dhcp
echo "option domain-name-servers 8.8.8.8;" >> salida.dhcp
echo "Introduce la ip de puerta de salida "
read var_salida
echo "option routers $var_salida;" >> salida.dhcp
echo "Introduce la ip de broadcast de la red"
read var_broad
echo "option broadcast-address $var_broad;" >> salida.dhcp
echo "default-lease-time 600;" >> salida.dhcp
echo "max-lease-time 7200;" >> salida.dhcp
echo "Introduce la ip del servidor "
read var_ser
echo "next-server $var_ser;" >> salida.dhcp
echo "filename \"grldr\";" >> salida.dhcp
echo "use-host-decl-names on;" >> salida.dhcp
echo " " >> salida.dhcp
echo "###########################################" >> salida.dhcp
echo "############## biblioteca #################" >> salida.dhcp
echo "###########################################" >> salida.dhcp

## Generación del bloque de ips
# ejemplo de bib=('Arq BeA Sal Com Der Eco Edu Fis Hum Inf Ing Inf Agr Mat Pol Tur')



bib=`awk "NR==1" $1` 
echo $bib
# Datos para la generación
lbib=3

for i in $bib; do
auxcut=`awk "NR==$lbib" $1`
intbuc=`echo $auxcut | cut -d " " -f 1 `
extbuc=`echo $auxcut | cut -d " " -f 2 `

echo $intbuc
echo $extbuc

#### Comprabacion de los datos introducidos 
        if [ $intbuc -gt 35  ];then
        echo "Mayor cantidad de equipos rojos de los permitidos "
	fi

	aux=$((45 -$intbuc)) 
	if [ $aux -lt $extbuc  ];then
        echo "Mayor cantidad de portatiles que de huecos, se pasa a dividir el espacio  "
	flag=0
	else
	echo "Tenemos hueco para insertar los equipos"  	
        flag=1 	
	fi


## ejecución con hueco de sobra para todos los equipos

 if [ $flag -eq 1 ];then
	while [ $intbuc -gt "0" ]
	do
        lbib=$(($lbib+1))
    	echo " host	R$i-$dig3_$dig4  { hardware	ethernet	`awk "NR==$lbib" $1`;	fixed-address	10.1.$dig3.$dig4;	option	host-name	R$i-$dig3_$dig4;}   #ROJO$i " >> salida.dhcp
   	 dig4=$(($dig4 + 1))
 

	if [ $dig4 -eq 256 ]; then
	dig4=0
	dig3=$(($dig3 + 1))
	fi
	 intbuc=$(($intbuc - 1))		    	
	done

	while [ $extbuc -gt "0" ]
	do	
	lbib=$((lbib  + 1))
    	echo " host	P$i-$dig3_$dig4  { hardware     ethernet         `awk "NR==$lbib" $1`;      fixed-address   10.1.$dig3.$dig4;	option  host-name       R$i-$dig3_$dig4;}   #PRESTAMO$i " >> salida.dhcp
	dig4=$(($dig4 + 1))


	if [ $dig4 -eq 256 ]; then
        dig4=0
        dig3=$(($dig3 + 1))
	fi

	extbuc=$(($extbuc - 1))
	done

###   Ejecución en caso de necesitar subdivisiones en los portatiles 
 else
########################  AJUSTE  ########################
	if [ $(($extbuc / 2)) -lt $aux ]; then
	 letras='a b'
	echo "letras1 $letras"
	adjust=:$(($extbuc / 2 ))	
  echo "$adjust"

 	elif [ $(($extbuc / 4)) -lt $aux ]; then 
	  letras='a b c d'
	adjust=$(($extbuc / 4 ))
	echo "letras2" 
	echo "$letras"
  echo "$adjust"

        elif [ $(($extbuc / 6)) -lt $aux ]; then
	
	adjust=$(($extbuc / 6 ))	       
	letras=('a b c d e f')
        echo "$adjust"
	fi
##########################################################
	
        while [ $intbuc -gt "0" ]
        do
	lbib=$((lbib  + 1))
        echo " host     R$i-$dig3_$dig4  { hardware     ethernet        `awk "NR==$lbib" $1`;      fixed-address   10.1.$dig3.$dig4;       option  host-name       R$i-$dig3_$dig4;}   #ROJO$i " >> salida.dhcp
         dig4=$(($dig4 + 1))

        if [ $dig4 -eq 256 ]; then
        dig4=0
        dig3=$(($dig3 + 1))
        fi
         intbuc=$(($intbuc - 1))                        
        done

        while [ $adjust -gt "0" ]
        do 
	
	for x in $letras; do      
	lbib=$((lbib  + 1))
        echo " host     R$i-$dig4-$x  { hardware     ethernet        `awk "NR==$lbib" $1`;      fixed-address   10.1.$dig3.$dig4;       option  host-name       R$i-$dig3_$dig4;}   #PRESTAMO$i " >> salida.dhcp

	done	       

	dig4=$(($dig4 + 1))

        if [ $dig4 -eq 256 ]; then
        dig4=0
        dig3=$(($dig3 + 1))
        fi

        adjust=$(($adjust - 1))
        

	done	



fi 
lbib=$(($lbib+3))
done
