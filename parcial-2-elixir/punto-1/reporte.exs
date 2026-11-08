defmodule Reporte do
  @linea_doble String.duplicate("=", 70)
  @linea_simple String.duplicate("-", 70)

  # Construye el reporte de todas las ciudades válidas y los rechazados por archivo.
  # datos es el mapa que retorna Coordinador.obtener_datos/2.
  def reporte_general(datos) do
    encabezado = [
      @linea_doble,
      "OBSERVATORIO SISMOLÓGICO - UNIVERSIDAD DEL QUINDÍO",
      "REPORTE DE SISMOS POR CIUDAD",
      @linea_doble
    ]

    secciones_ciudades =
      Enum.map(datos.ciudades, fn ciudad ->
        reporte_ciudad(ciudad, datos.movimientos) <> "\n" <> @linea_simple
      end)

    rechazados = [
      "REGISTROS RECHAZADOS",
      "  ciudades.txt: #{datos.rechazados_ciudades}",
      "  movimientos.txt: #{datos.rechazados_movimientos}",
      @linea_doble
    ]

    Enum.join(encabezado ++ secciones_ciudades ++ rechazados, "\n")
  end

  # Busca la ciudad por su identificador y construye su reporte.
  def reporte_por_id(datos, id_ciudad) do
    case Enum.find(datos.ciudades, fn ciudad -> ciudad.id == id_ciudad end) do
      nil -> "La ciudad no está registrada"
      ciudad -> reporte_ciudad(ciudad, datos.movimientos)
    end
  end

  # Construye el reporte de una sola ciudad a partir de todos los movimientos válidos.
  def reporte_ciudad(ciudad, todos_los_movimientos) do
    movimientos = Estadisticas.movimientos_de_ciudad(todos_los_movimientos, ciudad.id)
    estadisticas = Estadisticas.calcular(movimientos)

    lineas =
      [
        "Ciudad: #{ciudad.nombre} (#{ciudad.id})",
        "Habitantes: #{ciudad.habitantes}",
        "Movimientos:"
      ] ++
        lineas_movimientos(movimientos) ++
        [
          "Total de movimientos: #{estadisticas.cantidad}",
          "Movimiento de mayor magnitud: #{texto_mayor(estadisticas.mayor)}",
          "Profundidad promedio: #{texto_promedio(estadisticas.promedio)}"
        ]

    Enum.join(lineas, "\n")
  end

  defp lineas_movimientos([]), do: ["  Sin movimientos registrados"]

  defp lineas_movimientos(movimientos) do
    Enum.map(movimientos, fn movimiento ->
      "  - #{movimiento.codigo} | Inicio: #{movimiento.hora_inicio}" <>
        " | Final: #{movimiento.hora_final}" <>
        " | Magnitud: #{movimiento.magnitud}" <>
        " | Profundidad: #{movimiento.profundidad} km"
    end)
  end

  defp texto_mayor(nil), do: "No aplica"
  defp texto_mayor(movimiento), do: "#{movimiento.codigo} · #{movimiento.magnitud}"

  defp texto_promedio(nil), do: "No aplica"
  defp texto_promedio(promedio), do: "#{dos_decimales(promedio)} km"

  # Convierte el número en texto con exactamente dos decimales (14.0 -> "14.00").
  defp dos_decimales(numero) do
    :erlang.float_to_binary(numero, decimals: 2)
  end
end
