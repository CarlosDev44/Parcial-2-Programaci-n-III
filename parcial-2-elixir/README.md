# Parcial II - Programación 3 (Elixir)

Requisito: tener Elixir instalado.


## Punto 1 - Reporte local

Comando para ejecutar el programa, desde la carpeta punto-1:

    cd punto-1
    elixir main.exs

Archivos de entrada: punto-1/resources/ciudades.txt y punto-1/resources/movimientos.txt
Reporte que se genera: punto-1/resources/reporte_sismos.txt


## Punto 2 - Consulta entre nodos

Se necesitan dos terminales. Primero se inicia el servidor y luego el cliente.

Nodo servidor: servidor@127.0.0.1
Nodo cliente: cliente@127.0.0.1
Cookie: sismos (la misma en ambos nodos).

Cada script configura el nombre del nodo y la cookie por dentro (Node.start y Node.set_cookie), por eso el comando solo lleva el nombre del archivo. Es equivalente a ejecutar con las opciones completas:

    elixir --name servidor@127.0.0.1 --cookie sismos servidor.exs
    elixir --name cliente@127.0.0.1 --cookie sismos cliente.exs

### Paso a paso

1. Terminal 1 (servidor), desde la carpeta punto-2/nodo-servidor:

    cd punto-2/nodo-servidor
    elixir servidor.exs

   Debe aparecer: Servidor servidor@127.0.0.1 esperando solicitudes... Dejar esta terminal abierta.

2. Terminal 2 (cliente), desde la carpeta punto-2/nodo-cliente:

    cd punto-2/nodo-cliente
    elixir cliente.exs

   El cliente muestra las cuatro respuestas y termina al recibir :fin.


### Verificación del punto 2

Identificadores usados para la prueba:

    Ciudad con movimientos: C01 (Armenia)
    Ciudad sin movimientos: C03 (Circasia)
    Ciudad inexistente: C99

Segunda ejecución con el mismo servidor: sin cerrar la Terminal 1, volver a ejecutar en la Terminal 2, desde la carpeta punto-2/nodo-cliente:

    elixir cliente.exs

Se obtienen las mismas cuatro respuestas, lo que comprueba que el servidor sigue atendiendo solicitudes.


## Reflexión sobre el uso de inteligencia artificial

### 1. Herramientas y agentes

Utilizamos ChatGpt para analizar el parcial, desmembrarlo y ver como seria el flujo de salida del codigo y Claude para ayudas e ideas de codificacion.

### 2. Caso decisivo




### 3. Idea diferente de la clase


### 4. Conclusiones
