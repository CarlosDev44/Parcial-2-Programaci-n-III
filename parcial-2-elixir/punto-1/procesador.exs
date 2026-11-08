defmodule Procesador do
  # Convierte las líneas de ciudades.txt en structs Ciudad.
  # Retorna {ciudades_validas, cantidad_rechazados}.
  def procesar_ciudades(lineas) do
    procesar_lineas(lineas, &crear_ciudad/1, [], 0)
  end

  # Convierte las líneas de movimientos.txt en structs Movimiento.
  # Retorna {movimientos_validos, cantidad_rechazados}.
  def procesar_movimientos(lineas) do
    procesar_lineas(lineas, &crear_movimiento/1, [], 0)
  end

  # Separa los movimientos cuya ciudad existe en el catálogo de los que no.
  # Retorna {movimientos_validos, cantidad_rechazados}.
  def separar_por_ciudad(movimientos, ciudades) do
    ids_validos = Enum.map(ciudades, fn ciudad -> ciudad.id end)

    validos =
      Enum.filter(movimientos, fn movimiento ->
        Enum.member?(ids_validos, movimiento.id_ciudad)
      end)

    {validos, length(movimientos) - length(validos)}
  end

  # Recorre las líneas una por una.
  # crear_registro es la función que convierte una línea en struct (ciudad o movimiento).
  # Los válidos se acumulan al inicio de la lista, por eso al final se invierte
  # para conservar el orden del archivo.
  defp procesar_lineas([], _crear_registro, validos, rechazados) do
    {Enum.reverse(validos), rechazados}
  end

  defp procesar_lineas([linea | resto], crear_registro, validos, rechazados) do
    linea_limpia = String.trim(linea)

    if linea_limpia == "" do
      procesar_lineas(resto, crear_registro, validos, rechazados)
    else
      case crear_registro.(linea_limpia) do
        {:ok, registro} -> procesar_lineas(resto, crear_registro, [registro | validos], rechazados)
        :error -> procesar_lineas(resto, crear_registro, validos, rechazados + 1)
      end
    end
  end

  # Formato: idCiudad@nombre@numeroHabitantes
  # Retorna {:ok, %Ciudad{}} o :error.
  def crear_ciudad(linea) do
    case separar_campos(linea) do
      [id, nombre, texto_habitantes] -> validar_ciudad(id, nombre, texto_habitantes)
      _ -> :error
    end
  end

  # Formato: código@idCiudad@horaInicio@horaFinal@magnitud@profundidad
  # Retorna {:ok, %Movimiento{}} o :error.
  def crear_movimiento(linea) do
    campos = separar_campos(linea)

    if length(campos) == 6 do
      validar_movimiento(campos)
    else
      :error
    end
  end

  defp validar_ciudad(id, nombre, texto_habitantes) do
    habitantes = Validador.convertir_habitantes(texto_habitantes)

    cond do
      not Validador.campos_completos?([id, nombre, texto_habitantes]) -> :error
      habitantes == nil -> :error
      true -> {:ok, %Ciudad{id: id, nombre: nombre, habitantes: habitantes}}
    end
  end

  defp validar_movimiento(campos) do
    [codigo, id_ciudad, hora_inicio, hora_final, texto_magnitud, texto_profundidad] = campos
    magnitud = Validador.convertir_decimal(texto_magnitud)
    profundidad = Validador.convertir_profundidad(texto_profundidad)

    cond do
      not Validador.campos_completos?(campos) -> :error
      not Validador.hora_valida?(hora_inicio) -> :error
      not Validador.hora_valida?(hora_final) -> :error
      magnitud == nil -> :error
      profundidad == nil -> :error
      true ->
        {:ok,
         %Movimiento{
           codigo: codigo,
           id_ciudad: id_ciudad,
           hora_inicio: hora_inicio,
           hora_final: hora_final,
           magnitud: magnitud,
           profundidad: profundidad
         }}
    end
  end

  defp separar_campos(linea) do
    linea
    |> String.split("@")
    |> Enum.map(fn campo -> String.trim(campo) end)
  end
end
