import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    status: String,
    url: String
  }

  connect() {
    this.element.classList.add("animate__animated", "animate__fadeIn");
    this.checkStatus();
  }

  statusValueChanged() {
    this.checkStatus();
  }

  checkStatus() {
    if (this.statusValue === 'ready') {
      setTimeout(() => {
        Turbo.visit(this.urlValue, { action: "replace" });
      }, 1000); // Adjust based on Animate.css animation duration (default is 1s)
    }
  }
}
