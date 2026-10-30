import { Controller } from "@hotwired/stimulus"

// Abre o diálogo de impressão do navegador. Uso: data-action="impressao#imprimir".
export default class extends Controller {
  imprimir() {
    window.print()
  }
}
