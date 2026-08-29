puts "🌱 Criando dados iniciais para demonstração do Agenda AI..."

# 1. Tenant Demo
tenant = Tenant.find_or_initialize_by(slug: "salao-demo")
tenant.name = "Salão Beleza & Estilo"
tenant.phone = "(11) 98765-4321"
tenant.timezone = "America/Sao_Paulo"
tenant.primary_color = "#6366f1"
tenant.secondary_color = "#8b5cf6"
tenant.plan = "pro"
tenant.trial_ends_at = 14.days.from_now
tenant.save!

# Configurações do Tenant
setting = tenant.tenant_setting || tenant.create_tenant_setting!
setting.update!(
  cancellation_window_hours: 12,
  reminder_hours: 24,
  allow_reschedule: true,
  notification_channels: "email,whatsapp"
)

# 2. Admin User Demo
user = User.find_or_initialize_by(email: "admin@demo.com")
user.tenant = tenant
user.name = "Carlos Administrador"
user.password = "password123"
user.password_confirmation = "password123"
user.role = "admin"
user.save!

# 3. Services
corte = Service.find_or_initialize_by(tenant: tenant, name: "Corte de Cabelo Premium")
corte.description = "Corte personalizado com lavagem, finalização e massagem capilar."
corte.duration_minutes = 45
corte.price_in_reais = 60.00
corte.active = true
corte.sort_order = 1
corte.save!

barba = Service.find_or_initialize_by(tenant: tenant, name: "Barba Terapia com Toalha Quente")
barba.description = "Alinhamento com navalha, toalha quente e óleos essenciais hidratantes."
barba.duration_minutes = 30
barba.price_in_reais = 45.00
barba.active = true
barba.sort_order = 2
barba.save!

combo = Service.find_or_initialize_by(tenant: tenant, name: "Combo Cabelo + Barba Completo")
combo.description = "Experiência completa de cuidado capilar e barba com produtos premium."
combo.duration_minutes = 75
combo.price_in_reais = 95.00
combo.active = true
combo.sort_order = 3
combo.save!

escova = Service.find_or_initialize_by(tenant: tenant, name: "Corte Feminino & Escova")
escova.description = "Higienização profunda, corte estruturado e escova modeladora."
escova.duration_minutes = 60
escova.price_in_reais = 120.00
escova.active = true
escova.sort_order = 4
escova.save!

# 4. Professionals
lucas = Professional.find_or_initialize_by(tenant: tenant, name: "Lucas Barbeiro")
lucas.email = "lucas@salaodemo.com"
lucas.phone = "(11) 97777-1111"
lucas.bio = "Especialista em cortes clássicos e visagismo moderno com 8 anos de experiência."
lucas.buffer_minutes = 10
lucas.active = true
lucas.services = [ corte, barba, combo ]
lucas.save!

mariana = Professional.find_or_initialize_by(tenant: tenant, name: "Mariana Stylist")
mariana.email = "mariana@salaodemo.com"
mariana.phone = "(11) 98888-2222"
mariana.bio = "Mestre em colorimetria e cortes modernos femininos e masculinos."
mariana.buffer_minutes = 15
mariana.active = true
mariana.services = [ corte, combo, escova ]
mariana.save!

# 5. Availabilities for Lucas (Seg a Sex: 09:00 às 18:00, Sáb: 09:00 às 14:00)
(1..5).each do |day|
  avail = Availability.find_or_initialize_by(professional: lucas, day_of_week: day)
  avail.start_time = Time.zone.parse("09:00")
  avail.end_time = Time.zone.parse("18:00")
  avail.save!
end

avail_sat = Availability.find_or_initialize_by(professional: lucas, day_of_week: 6)
avail_sat.start_time = Time.zone.parse("09:00")
avail_sat.end_time = Time.zone.parse("14:00")
avail_sat.save!

# Availabilities for Mariana (Ter a Sáb: 10:00 às 19:00)
(2..6).each do |day|
  avail = Availability.find_or_initialize_by(professional: mariana, day_of_week: day)
  avail.start_time = Time.zone.parse("10:00")
  avail.end_time = Time.zone.parse("19:00")
  avail.save!
end

# 6. Sample Time Block for Lucas
block = TimeBlock.find_or_initialize_by(professional: lucas, reason: "Consulta Médica", start_date: Date.current + 3.days)
block.end_date = Date.current + 3.days
block.start_time = Time.zone.parse("14:00")
block.end_time = Time.zone.parse("16:00")
block.all_day = false
block.save!

# 7. Realistic Clients
clients_data = [
  { name: "Roberto Silva", email: "roberto.silva@exemplo.com", phone: "(11) 99111-2233" },
  { name: "Juliana Mendes", email: "juliana.mendes@exemplo.com", phone: "(11) 99222-3344" },
  { name: "Felipe Santos", email: "felipe.santos@exemplo.com", phone: "(11) 99333-4455" },
  { name: "Camila Rodrigues", email: "camila.rodrigues@exemplo.com", phone: "(11) 99444-5566" },
  { name: "Diego Oliveira", email: "diego.oliveira@exemplo.com", phone: "(11) 99555-6677" },
  { name: "Patrícia Costa", email: "patricia.costa@exemplo.com", phone: "(11) 99666-7788" }
]

clients = clients_data.map do |data|
  c = Client.find_or_initialize_by(tenant: tenant, email: data[:email])
  c.name = data[:name]
  c.phone = data[:phone]
  c.save!
  c
end

# 8. Historical & Upcoming Appointments
Time.use_zone("America/Sao_Paulo") do
  today = Date.current

  # Atendimentos Concluídos nos últimos dias (gerando faturamento no dashboard)
  [
    { client: clients[0], prof: lucas, srv: corte, date: today - 4.days, hour: 10, status: "completed" },
    { client: clients[1], prof: mariana, srv: escova, date: today - 3.days, hour: 14, status: "completed" },
    { client: clients[2], prof: lucas, srv: combo, date: today - 2.days, hour: 11, status: "completed" },
    { client: clients[3], prof: mariana, srv: corte, date: today - 1.day, hour: 16, status: "completed" },
    { client: clients[4], prof: lucas, srv: barba, date: today - 1.day, hour: 15, status: "completed" }
  ].each do |appt_info|
    start_time = Time.zone.local(appt_info[:date].year, appt_info[:date].month, appt_info[:date].day, appt_info[:hour], 0)
    appt = Appointment.find_or_initialize_by(
      tenant: tenant,
      client: appt_info[:client],
      professional: appt_info[:prof],
      starts_at: start_time
    )
    appt.service = appt_info[:srv]
    appt.ends_at = start_time + appt_info[:srv].duration_minutes.minutes
    appt.price_cents = appt_info[:srv].price_cents
    appt.status = appt_info[:status]
    appt.save!
  end

  # Atendimentos de Hoje (Fila em tempo real na Dashboard)
  [
    { client: clients[0], prof: lucas, srv: corte, hour: 9, status: "completed" },
    { client: clients[5], prof: lucas, srv: barba, hour: 11, status: "confirmed" },
    { client: clients[1], prof: mariana, srv: escova, hour: 14, status: "confirmed" },
    { client: clients[2], prof: lucas, srv: combo, hour: 16, status: "confirmed" }
  ].each do |appt_info|
    start_time = Time.zone.local(today.year, today.month, today.day, appt_info[:hour], 0)
    appt = Appointment.find_or_initialize_by(
      tenant: tenant,
      client: appt_info[:client],
      professional: appt_info[:prof],
      starts_at: start_time
    )
    appt.service = appt_info[:srv]
    appt.ends_at = start_time + appt_info[:srv].duration_minutes.minutes
    appt.price_cents = appt_info[:srv].price_cents
    appt.status = appt_info[:status]
    appt.save!
  end

  # Atendimento Cancelado
  cancel_start = Time.zone.local(today.year, today.month, today.day, 17, 0)
  cancel_appt = Appointment.find_or_initialize_by(
    tenant: tenant,
    client: clients[3],
    professional: lucas,
    starts_at: cancel_start
  )
  cancel_appt.service = corte
  cancel_appt.ends_at = cancel_start + corte.duration_minutes.minutes
  cancel_appt.price_cents = corte.price_cents
  cancel_appt.status = "cancelled"
  cancel_appt.cancelled_by = "client"
  cancel_appt.cancellation_reason = "Imprevisto no trabalho"
  cancel_appt.cancelled_at = 1.hour.ago
  cancel_appt.save!

  # Atendimento No-Show Passado
  noshow_start = Time.zone.local((today - 2.days).year, (today - 2.days).month, (today - 2.days).day, 16, 0)
  noshow_appt = Appointment.find_or_initialize_by(
    tenant: tenant,
    client: clients[4],
    professional: mariana,
    starts_at: noshow_start
  )
  noshow_appt.service = corte
  noshow_appt.ends_at = noshow_start + corte.duration_minutes.minutes
  noshow_appt.price_cents = corte.price_cents
  noshow_appt.status = "no_show"
  noshow_appt.save!
  clients[4].update!(no_show_count: 1)

  # Atendimentos Futuros Confirmados
  [
    { client: clients[0], prof: lucas, srv: combo, date: today + 1.day, hour: 10 },
    { client: clients[1], prof: mariana, srv: escova, date: today + 1.day, hour: 15 },
    { client: clients[2], prof: lucas, srv: corte, date: today + 2.days, hour: 11 },
    { client: clients[5], prof: mariana, srv: corte, date: today + 2.days, hour: 14 }
  ].each do |appt_info|
    start_time = Time.zone.local(appt_info[:date].year, appt_info[:date].month, appt_info[:date].day, appt_info[:hour], 0)
    appt = Appointment.find_or_initialize_by(
      tenant: tenant,
      client: appt_info[:client],
      professional: appt_info[:prof],
      starts_at: start_time
    )
    appt.service = appt_info[:srv]
    appt.ends_at = start_time + appt_info[:srv].duration_minutes.minutes
    appt.price_cents = appt_info[:srv].price_cents
    appt.status = "confirmed"
    appt.save!

    # Criar registro de notificação
    Notification.find_or_create_by!(
      appointment: appt,
      channel: "email",
      notification_type: "confirmation",
      status: "sent",
      sent_at: Time.current
    )
  end
end

puts "✅ Seed concluído com sucesso!"
puts "🏢 Tenant: #{tenant.name} (slug: #{tenant.slug})"
puts "👤 Usuário Admin: #{user.email} / password123"
puts "✂️ Serviços: #{Service.count} cadastrados"
puts "💈 Profissionais: #{Professional.count} cadastrados"
puts "👥 Clientes: #{Client.count} cadastrados"
puts "📅 Agendamentos: #{Appointment.count} (Concluídos, Confirmados, Cancelados e No-Show)"
puts "🔔 Notificações: #{Notification.count} geradas"
