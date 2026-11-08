defmodule Movimiento do
  # Representa una línea válida de resources/movimientos.txt.
  # magnitud y profundidad se guardan como números decimales (float).
  defstruct codigo: nil,
            id_ciudad: nil,
            hora_inicio: nil,
            hora_final: nil,
            magnitud: 0.0,
            profundidad: 0.0
end
