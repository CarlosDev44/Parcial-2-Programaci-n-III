defmodule Coordinador do
  # El proceso que llama esta función actúa como coordinador:
  # 1. Inicia los dos trabajadores con spawn (sin esperar entre uno y otro).
  # 2. Espera las dos respuestas con receive, en cualquier orden.
  # 3. Combina los resultados.
  # Retorna {:ok, datos} o {:error, mensajes_de_error}.
  def obtener_datos(ruta_ciudades, ruta_movimientos) do
    coordinador = self()

    spawn(fn -> trabajador_ciudades(coordinador, ruta_ciudades) end)
    spawn(fn -> trabajador_movimientos(coordinador, ruta_movimientos) end)

    {resultado_ciudades, resultado_movimientos} = esperar_respuestas(nil, nil)
    combinar_resultados(resultado_ciudades, resultado_movimientos, ruta_ciudades, ruta_movimientos)
  end

  # Trabajador 1: lee y procesa ciudades.txt y avisa al coordinador.
  # Mensaje enviado: {:archivo_procesado, :ciudades, resultado}
  def trabajador_ciudades(coordinador, ruta) do
    resultado =
      case Archivos.leer_lineas(ruta) do
        {:ok, lineas} ->
          {ciudades, rechazados} = Procesador.procesar_ciudades(lineas)
          {:ok, ciudades, rechazados}

        {:error, razon} ->
          {:error, razon}
      end

    send(coordinador, {:archivo_procesado, :ciudades, resultado})
  end

  # Trabajador 2: lee y procesa movimientos.txt y avisa al coordinador.
  # Mensaje enviado: {:archivo_procesado, :movimientos, resultado}
  def trabajador_movimientos(coordinador, ruta) do
    resultado =
      case Archivos.leer_lineas(ruta) do
        {:ok, lineas} ->
          {movimientos, rechazados} = Procesador.procesar_movimientos(lineas)
          {:ok, movimientos, rechazados}

        {:error, razon} ->
          {:error, razon}
      end

    send(coordinador, {:archivo_procesado, :movimientos, resultado})
  end

  # Espera recursivamente hasta tener las dos respuestas.
  # nil significa "todavía no ha llegado", por eso el orden de llegada no importa.
  defp esperar_respuestas(resultado_ciudades, resultado_movimientos)
       when resultado_ciudades != nil and resultado_movimientos != nil do
    {resultado_ciudades, resultado_movimientos}
  end

  defp esperar_respuestas(resultado_ciudades, resultado_movimientos) do
    receive do
      {:archivo_procesado, :ciudades, resultado} ->
        esperar_respuestas(resultado, resultado_movimientos)

      {:archivo_procesado, :movimientos, resultado} ->
        esperar_respuestas(resultado_ciudades, resultado)
    end
  end

  # Solo si ambos archivos se leyeron bien se arman los datos del reporte.
  # Aquí se rechazan los movimientos cuya ciudad no existe en el catálogo.
  defp combinar_resultados(
         {:ok, ciudades, rechazados_ciudades},
         {:ok, movimientos, rechazados_movimientos},
         _ruta_ciudades,
         _ruta_movimientos
       ) do
    {movimientos_validos, sin_ciudad} = Procesador.separar_por_ciudad(movimientos, ciudades)

    {:ok,
     %{
       ciudades: ciudades,
       movimientos: movimientos_validos,
       rechazados_ciudades: rechazados_ciudades,
       rechazados_movimientos: rechazados_movimientos + sin_ciudad
     }}
  end

  defp combinar_resultados(resultado_ciudades, resultado_movimientos, ruta_ciudades, ruta_movimientos) do
    mensajes =
      mensaje_si_error(resultado_ciudades, "ciudades", ruta_ciudades) ++
        mensaje_si_error(resultado_movimientos, "movimientos", ruta_movimientos)

    {:error, mensajes}
  end

  defp mensaje_si_error({:error, razon}, nombre, ruta) do
    ["Error al leer el archivo de #{nombre} (#{ruta}): #{Archivos.describir_error(razon)}"]
  end

  defp mensaje_si_error(_resultado_correcto, _nombre, _ruta), do: []
end
