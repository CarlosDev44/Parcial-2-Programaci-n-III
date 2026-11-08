defmodule Validador do
  # Retorna true si ninguno de los campos está vacío.
  def campos_completos?(campos) do
    Enum.all?(campos, fn campo -> campo != "" end)
  end

  # Una hora es válida si tiene la forma HH:MM:SS y está entre 00:00:00 y 23:59:59.
  def hora_valida?(texto) do
    case String.split(texto, ":") do
      [horas, minutos, segundos] ->
        numero_en_rango?(horas, 0, 23) and
          numero_en_rango?(minutos, 0, 59) and
          numero_en_rango?(segundos, 0, 59)

      _ ->
        false
    end
  end

  # Convierte el texto en decimal. Retorna el número o nil si no es válido.
  # Float.parse debe consumir todo el texto: "3.4abc" no es válido.
  def convertir_decimal(texto) do
    case Float.parse(texto) do
      {numero, ""} -> numero
      _ -> nil
    end
  end

  # La profundidad es un decimal mayor o igual a cero. Retorna el número o nil.
  def convertir_profundidad(texto) do
    numero = convertir_decimal(texto)

    if numero != nil and numero >= 0 do
      numero
    else
      nil
    end
  end

  # Los habitantes son un entero mayor que cero. Retorna el número o nil.
  def convertir_habitantes(texto) do
    case Integer.parse(texto) do
      {numero, ""} when numero > 0 -> numero
      _ -> nil
    end
  end

  # Verifica que el texto tenga exactamente dos dígitos y esté en el rango indicado.
  defp numero_en_rango?(texto, minimo, maximo) do
    if String.match?(texto, ~r/^[0-9]{2}$/) do
      numero = String.to_integer(texto)
      numero >= minimo and numero <= maximo
    else
      false
    end
  end
end
