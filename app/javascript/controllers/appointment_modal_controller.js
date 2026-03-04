import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["backdrop", "title", "serviceId"];

  open(event){
    event.preventDefault();

    const dataset = event.currentTarget.dataset;

    const serviceId = dataset.appointmentModalServiceIdValue;
    const serviceName = dataset.appointmentModalServiceNameValue;
    const nutritionistName = dataset.appointmentModalNutritionistNameValue;

    this.serviceIdTarget.value = serviceId || "";

    const parts = [nutritionistName, serviceName].filter(Boolean);
    this.titleTarget.textContent = parts.length
      ? `Schedule — ${parts.join(" · ")}`
      : "Schedule appointment";

    this.backdropTarget.classList.add("is-open");

    this.backdropTarget.querySelector("input, select, textarea, button")?.focus();
  }

  close() {
    this.backdropTarget.classList.remove("is-open");
    // clean forms
    this.backdropTarget.querySelector("form")?.reset();
  }

  backdropClose(event) {
    if (event.target === this.backdropTarget) this.close();
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close();
  }
}