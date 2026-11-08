# Punto 2 - Nodo servidor.
# Ejecutar desde la carpeta punto-2/nodo-servidor con:
#   elixir servidor.exs

# Se reutilizan los structs, validaciones, cálculos y reportes del punto 1.
carpeta_punto_1 = Path.join(__DIR__, "../../punto-1")
Code.require_file("ciudad.exs", carpeta_punto_1)
Code.require_file("movimiento.exs", carpeta_punto_1)
Code.require_file("archivos.exs", carpeta_punto_1)
Code.require_file("validador.exs", carpeta_punto_1)
Code.require_file("procesador.exs", carpeta_punto_1)
Code.require_file("estadisticas.exs", carpeta_punto_1)
Code.require_file("reporte.exs", carpeta_punto_1)
Code.require_file("coordinador.exs", carpeta_punto_1)

defmodule ServidorSismos do
  @ruta_ciudades Path.join(__DIR__, "resources/ciudades.txt")
  @ruta_movimientos Path.join(__DIR__, "resources/movimientos.txt")

  def iniciar do
    # El nodo y la cookie se configuran aquí, por eso basta con: elixir servidor.exs
    Node.start(:"servidor@127.0.0.1", :longnames)
    Node.set_cookie(:sismos)
    Process.register(self(), :servicio_sismos)
    IO.puts("Servidor #{node()} esperando solicitudes en :servicio_sismos ...")
    atender_solicitudes()
  end

  # Un solo proceso atiende los mensajes uno por uno, en el orden en que llegan.
  # Por eso las respuestas salen en el mismo orden de las solicitudes.
  defp atender_solicitudes do
    receive do
      {destino_respuesta, :fin} ->
        IO.puts("Solicitud recibida: :fin")
        send(destino_respuesta, :fin)

      {destino_respuesta, solicitud} ->
        IO.puts("Solicitud recibida: #{inspect(solicitud)}")
        send(destino_respuesta, {:respuesta, solicitud, procesar_solicitud(solicitud)})
    end

    atender_solicitudes()
  end

  # Cada consulta vuelve a leer los archivos de forma concurrente (Coordinador del punto 1).
  defp procesar_solicitud({:reporte_ciudad, id_ciudad}) do
    case Coordinador.obtener_datos(@ruta_ciudades, @ruta_movimientos) do
      {:ok, datos} -> Reporte.reporte_por_id(datos, id_ciudad)
      {:error, mensajes} -> Enum.join(mensajes, "\n")
    end
  end

  defp procesar_solicitud(:reporte_general) do
    case Coordinador.obtener_datos(@ruta_ciudades, @ruta_movimientos) do
      {:ok, datos} -> Reporte.reporte_general(datos)
      {:error, mensajes} -> Enum.join(mensajes, "\n")
    end
  end

  defp procesar_solicitud(_otra) do
    "Solicitud no reconocida"
  end
end

ServidorSismos.iniciar()
