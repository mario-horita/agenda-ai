import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["serviceCard", "professionalCard", "dateInput", "slotsContainer", "checkoutButton", "selectedSlotInfo", "selectedStartsAtInput", "selectedProfInput", "selectedServiceInput"]
  static values = {
    tenantSlug: String,
    serviceId: String,
    professionalId: String,
    selectedStartsAt: String
  }

  connect() {
    if (this.hasDateInputTarget && this.serviceIdValue) {
      this.loadSlots()
    }
  }

  selectService(event) {
    const card = event.currentTarget
    this.serviceIdValue = card.dataset.serviceId

    this.serviceCardTargets.forEach(el => {
      el.classList.remove("border-indigo-500", "bg-indigo-600/10")
      el.classList.add("border-slate-800", "bg-slate-900/50")
    })
    card.classList.add("border-indigo-500", "bg-indigo-600/10")
    card.classList.remove("border-slate-800", "bg-slate-900/50")

    if (this.hasSelectedServiceInputTarget) {
      this.selectedServiceInputTarget.value = this.serviceIdValue
    }

    this.loadSlots()
  }

  selectProfessional(event) {
    const card = event.currentTarget
    this.professionalIdValue = card.dataset.professionalId

    this.professionalCardTargets.forEach(el => {
      el.classList.remove("border-indigo-500", "bg-indigo-600/10")
      el.classList.add("border-slate-800", "bg-slate-900/50")
    })
    card.classList.add("border-indigo-500", "bg-indigo-600/10")
    card.classList.remove("border-slate-800", "bg-slate-900/50")

    if (this.hasSelectedProfInputTarget) {
      this.selectedProfInputTarget.value = this.professionalIdValue
    }

    this.loadSlots()
  }

  dateChanged() {
    this.loadSlots()
  }

  async loadSlots() {
    if (!this.hasSlotsContainerTarget || !this.serviceIdValue) return

    const date = this.hasDateInputTarget ? this.dateInputTarget.value : new Date().toISOString().split("T")[0]
    const profParam = this.professionalIdValue ? `&professional_id=${this.professionalIdValue}` : ""
    const url = `/${this.tenantSlugValue}/public/slots?service_id=${this.serviceIdValue}${profParam}&date=${date}`

    this.slotsContainerTarget.innerHTML = `
      <div class="p-8 text-center text-slate-400 text-xs flex items-center justify-center gap-2">
        <svg class="animate-spin h-4 w-4 text-indigo-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Buscando horários disponíveis...
      </div>
    `

    try {
      const response = await fetch(url, { credentials: "same-origin" })
      if (response.ok) {
        const html = await response.text()
        this.slotsContainerTarget.innerHTML = html

        // Attach click listeners to slot buttons
        const slotButtons = this.slotsContainerTarget.querySelectorAll("button[data-starts-at]")
        slotButtons.forEach(btn => {
          btn.addEventListener("click", () => this.selectSlot(btn))
        })
      } else {
        this.slotsContainerTarget.innerHTML = `
          <div class="p-6 rounded-2xl bg-rose-500/10 border border-rose-500/20 text-rose-300 text-xs text-center">
            Não foi possível carregar os horários.
          </div>
        `
      }
    } catch (e) {
      this.slotsContainerTarget.innerHTML = `
        <div class="p-6 rounded-2xl bg-rose-500/10 border border-rose-500/20 text-rose-300 text-xs text-center">
          Erro de conexão ao carregar horários.
        </div>
      `
    }
  }

  selectSlot(button) {
    const startsAt = button.dataset.startsAt
    const endsAt = button.dataset.endsAt
    const profId = button.dataset.professionalId

    // Highlight active button
    const allButtons = this.slotsContainerTarget.querySelectorAll("button[data-starts-at]")
    allButtons.forEach(b => {
      b.classList.remove("border-indigo-500", "bg-indigo-600", "text-white")
      b.classList.add("bg-slate-900", "border-slate-800", "text-slate-300")
    })
    button.classList.add("border-indigo-500", "bg-indigo-600", "text-white")
    button.classList.remove("bg-slate-900", "border-slate-800")

    if (this.hasSelectedStartsAtInputTarget) {
      this.selectedStartsAtInputTarget.value = startsAt
    }
    if (this.hasSelectedProfInputTarget && profId) {
      this.selectedProfInputTarget.value = profId
    }

    if (this.hasCheckoutButtonTarget) {
      this.checkoutButtonTarget.removeAttribute("disabled")
      this.checkoutButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    }

    const timeString = new Date(startsAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    if (this.hasSelectedSlotInfoTarget) {
      this.selectedSlotInfoTarget.textContent = `Horário selecionado: ${timeString}`
      this.selectedSlotInfoTarget.classList.remove("hidden")
    }
  }

  proceedToCheckout() {
    const startsAt = this.selectedStartsAtInputTarget?.value
    const serviceId = this.serviceIdValue
    const profId = this.selectedProfInputTarget?.value || this.professionalIdValue

    if (!startsAt || !serviceId || !profId) {
      alert("Por favor, selecione um serviço, profissional e horário.")
      return
    }

    window.location.href = `/${this.tenantSlugValue}/public/bookings/new?service_id=${serviceId}&professional_id=${profId}&starts_at=${encodeURIComponent(startsAt)}`
  }
}
