import { Controller } from "@hotwired/stimulus"

// Mostra no seletor de catraca só os grupos (optgroup) do restaurante escolhido.
export default class extends Controller {
  static targets = ["restaurante", "catraca"]

  connect() {
    this.filtrar()
  }

  filtrar() {
    const restaurante = this.restauranteTarget.value

    this.catracaTarget.querySelectorAll("optgroup").forEach((grupo) => {
      const visivel = !restaurante || grupo.dataset.restauranteId === restaurante
      grupo.hidden = !visivel
      grupo.disabled = !visivel
    })

    if (this.catracaTarget.selectedOptions[0]?.disabled) this.catracaTarget.value = ""
  }
}
