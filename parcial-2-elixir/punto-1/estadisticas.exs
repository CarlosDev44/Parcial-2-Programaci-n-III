defmodule Estadisticas do
  # Retorna los movimientos de una ciudad, en el mismo orden del archivo.
  def movimientos_de_ciudad(movimientos, id_ciudad) do
    Enum.filter(movimientos, fn movimiento -> movimiento.id_ciudad == id_ciudad end)
  end

  # Calcula las estadísticas de una lista de movimientos.
  # Retorna un mapa con :cantidad, :mayor (struct Movimiento o nil) y :promedio (float o nil).
  def calcular(movimientos) do
    {cantidad, mayor, suma_profundidades} = recorrer(movimientos, 0, nil, 0.0)

    %{
      cantidad: cantidad,
      mayor: mayor,
      promedio: calcular_promedio(suma_profundidades, cantidad)
    }
  end

  # Recursión explícita: en un solo recorrido acumula la cantidad,
  # el movimiento de mayor magnitud y la suma de profundidades.
  defp recorrer([], cantidad, mayor, suma) do
    {cantidad, mayor, suma}
  end

  defp recorrer([movimiento | resto], cantidad, mayor, suma) do
    recorrer(
      resto,
      cantidad + 1,
      elegir_mayor(mayor, movimiento),
      suma + movimiento.profundidad
    )
  end

  # Se usa ">" (y no ">=") para que, en un empate, se conserve el primero del archivo.
  defp elegir_mayor(nil, movimiento), do: movimiento

  defp elegir_mayor(mayor_actual, movimiento) do
    if movimiento.magnitud > mayor_actual.magnitud do
      movimiento
    else
      mayor_actual
    end
  end

  defp calcular_promedio(_suma, 0), do: nil
  defp calcular_promedio(suma, cantidad), do: suma / cantidad
end
