# Punto 1 - Reporte sísmico local.
# Ejecutar desde la carpeta punto-1 con:  elixir main.exs

Code.require_file("ciudad.exs", __DIR__)
Code.require_file("movimiento.exs", __DIR__)
Code.require_file("archivos.exs", __DIR__)
Code.require_file("validador.exs", __DIR__)
Code.require_file("procesador.exs", __DIR__)
Code.require_file("estadisticas.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)
Code.require_file("coordinador.exs", __DIR__)

defmodule ReporteLocal do
  # Genera el reporte, lo muestra en consola y lo guarda en el archivo de salida.
  # Si algún archivo de entrada falla, no se toca el reporte anterior.
  def ejecutar(ruta_ciudades, ruta_movimientos, ruta_reporte) do
    case Coordinador.obtener_datos(ruta_ciudades, ruta_movimientos) do
      {:ok, datos} ->
        texto = Reporte.reporte_general(datos)
        IO.puts(texto)
        guardar_reporte(ruta_reporte, texto)

      {:error, mensajes} ->
        IO.puts("No se pudo generar el reporte.")
        Enum.each(mensajes, fn mensaje -> IO.puts(mensaje) end)
        IO.puts("Se conserva el reporte anterior.")
    end
  end

  defp guardar_reporte(ruta_reporte, texto) do
    case Archivos.guardar_texto(ruta_reporte, texto <> "\n") do
      :ok ->
        IO.puts("\nReporte guardado en #{ruta_reporte}")

      {:error, razon} ->
        IO.puts("\nError al guardar el reporte en #{ruta_reporte}: #{Archivos.describir_error(razon)}")
    end
  end
end

carpeta_recursos = Path.join(__DIR__, "resources")

ReporteLocal.ejecutar(
  Path.join(carpeta_recursos, "ciudades.txt"),
  Path.join(carpeta_recursos, "movimientos.txt"),
  Path.join(carpeta_recursos, "reporte_sismos.txt")
)
