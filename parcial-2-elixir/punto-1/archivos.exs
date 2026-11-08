defmodule Archivos do
  # Lee un archivo de texto y devuelve sus líneas.
  # Retorna {:ok, lineas} o {:error, razon}.
  def leer_lineas(ruta) do
    case File.read(ruta) do
      {:ok, contenido} -> {:ok, String.split(contenido, "\n")}
      {:error, razon} -> {:error, razon}
    end
  end

  # Escribe el texto en la ruta indicada, reemplazando el contenido anterior.
  # Retorna :ok o {:error, razon}.
  def guardar_texto(ruta, texto) do
    File.write(ruta, texto)
  end

  # Convierte una razón de error (por ejemplo :enoent) en un texto legible.
  def describir_error(razon) do
    to_string(:file.format_error(razon))
  end
end
