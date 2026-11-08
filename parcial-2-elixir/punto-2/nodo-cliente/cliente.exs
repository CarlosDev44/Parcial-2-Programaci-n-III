# Punto 2 - Nodo cliente.
# Ejecutar desde la carpeta punto-2/nodo-cliente con:
#   elixir cliente.exs

defmodule ClienteSismos do
  @nodo_servidor :"servidor@127.0.0.1"
  @servicio_remoto :servicio_sismos

  # Identificadores de prueba (ver README).
  @ciudad_con_movimientos "C01"
  @ciudad_sin_movimientos "C03"
  @ciudad_inexistente "C99"

  def iniciar do
    # El nodo y la cookie se configuran aquí, por eso basta con: elixir cliente.exs
    Node.start(:"cliente@127.0.0.1", :longnames)
    Node.set_cookie(:sismos)
    Process.register(self(), :servicio_respuesta)

    case Node.connect(@nodo_servidor) do
      true ->
        IO.puts("Conectado a #{@nodo_servidor}")
        enviar_solicitudes()
        recibir_respuestas()

      _ ->
        IO.puts("Error: no se pudo conectar con el nodo #{@nodo_servidor}.")
        IO.puts("Verifique que el servidor esté iniciado y que ambos usen la misma cookie.")
    end
  end

  # Cada mensaje tiene la forma {destino_respuesta, solicitud}.
  # destino_respuesta = {nombre_registrado, nodo_cliente}
  defp enviar_solicitudes do
    destino_respuesta = {:servicio_respuesta, node()}
    servicio = {@servicio_remoto, @nodo_servidor}

    solicitudes = [
      {:reporte_ciudad, @ciudad_con_movimientos},
      {:reporte_ciudad, @ciudad_sin_movimientos},
      {:reporte_ciudad, @ciudad_inexistente},
      :reporte_general,
      :fin
    ]

    Enum.each(solicitudes, fn solicitud ->
      send(servicio, {destino_respuesta, solicitud})
    end)
  end

  # Recibe y muestra respuestas de forma recursiva hasta que llegue :fin.
  # El after evita que el cliente quede bloqueado si el servidor no responde.
  defp recibir_respuestas do
    receive do
      :fin ->
        IO.puts("\nEl servidor confirmó :fin. Cliente finalizado.")

      {:respuesta, solicitud, texto} ->
        IO.puts("\n>>> Respuesta a #{inspect(solicitud)}")
        IO.puts(texto)
        recibir_respuestas()
    after
      10_000 ->
        IO.puts("\nNo se recibió respuesta del servidor en 10 segundos. Cliente finalizado.")
    end
  end
end

ClienteSismos.iniciar()
