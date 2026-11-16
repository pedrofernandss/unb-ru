import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "mostrar", "ocultar"]

  toggle(event) {
    const revelar = this.inputTarget.type === "password"

    this.inputTarget.type = revelar ? "text" : "password"
    this.mostrarTarget.hidden = revelar
    this.ocultarTarget.hidden = !revelar

    const botao = event.currentTarget
    botao.setAttribute("aria-pressed", String(revelar))
    botao.setAttribute("aria-label", revelar ? "Ocultar senha" : "Mostrar senha")
  }
}
