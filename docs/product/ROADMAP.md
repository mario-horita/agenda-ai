# Roadmap — Agenda AI

> Priorizado usando **WSJF (Weighted Shortest Job First)**.
> Organizado em buckets: **Now** (MVP), **Next** (v1.1), **Later** (v2+).
> Última atualização: 2026-08-29

---

## 📊 WSJF Scoring

| # | Feature / Módulo | Business Value (1-10) | Time Criticality (1-10) | Opportunity (1-10) | CoD (soma) | Job Size (Fibonacci) | **WSJF** |
|---|------------------|-----------------------|-------------------------|---------------------|------------|----------------------|----------|
| 1 | Multi-Tenancy & Onboarding | 10 | 10 | 9 | 29 | 8 | **3.63** |
| 2 | Motor de Agendamento | 10 | 10 | 10 | 30 | 8 | **3.75** |
| 3 | Gestão de Profissionais & Serviços | 9 | 9 | 8 | 26 | 5 | **5.20** |
| 4 | Notificações (Email) | 8 | 8 | 9 | 25 | 5 | **5.00** |
| 5 | Dashboard Básico | 7 | 5 | 7 | 19 | 5 | **3.80** |
| 6 | Planos & Billing | 9 | 7 | 8 | 24 | 8 | **3.00** |
| 7 | Pagamento Online | 8 | 6 | 8 | 22 | 8 | **2.75** |
| 8 | Notificações WhatsApp | 7 | 6 | 9 | 22 | 5 | **4.40** |
| 9 | Personalização de Marca | 5 | 3 | 6 | 14 | 3 | **4.67** |
| 10 | Multi-localização | 6 | 2 | 7 | 15 | 13 | **1.15** |

> **Ordenação por WSJF (maior primeiro):** 3 → 4 → 9 → 8 → 5 → 2 → 1 → 6 → 7 → 10

---

## 🟢 NOW — MVP (Semanas 1-8)

> **Objetivo:** Lançar versão funcional que permita um negócio se cadastrar, configurar profissionais/serviços e receber agendamentos online com confirmação por email.

### Sprint 1-2: Fundação (Semanas 1-2)
- [x] Setup do projeto Rails 8 + Hotwire
- [ ] Configuração de multi-tenancy (acts_as_tenant ou scoping manual)
- [ ] Autenticação do Admin (Devise ou Rodauth)
- [ ] Modelo de dados: Tenant, User, Role

### Sprint 3-4: Coração do Produto (Semanas 3-4)
- [ ] CRUD de Profissionais (com disponibilidade semanal)
- [ ] CRUD de Serviços (duração, preço, vínculo com profissional)
- [ ] Bloqueio de horários (férias, folgas)
- [ ] Motor de cálculo de slots disponíveis

### Sprint 5-6: Experiência do Cliente (Semanas 5-6)
- [ ] Página pública de agendamento (booking page)
- [ ] Fluxo: Selecionar Serviço → Profissional → Data/Hora → Dados → Confirmar
- [ ] Prevenção de double-booking (lock otimístico)
- [ ] Cancelamento/reagendamento pelo cliente

### Sprint 7: Notificações & Dashboard (Semana 7)
- [ ] Email de confirmação (ActionMailer + Postmark/SendGrid)
- [ ] Lembrete automático 24h antes (Solid Queue)
- [ ] Dashboard básico: agendamentos do dia, semana, mês

### Sprint 8: Billing & Polish (Semana 8)
- [ ] Integração de planos (Starter gratuito / Pro trial 14d)
- [ ] Enforcement de limites por plano
- [ ] Testes E2E do fluxo completo
- [ ] Deploy em produção (Kamal + Docker)

**✅ Entregável:** SaaS funcional onde qualquer negócio pode se cadastrar, configurar sua equipe e receber agendamentos online.

---

## 🟡 NEXT — v1.1 (Semanas 9-14)

> **Objetivo:** Aumentar retenção e monetização com pagamentos, WhatsApp e personalização.

### Pagamento Online
- [ ] Integração Stripe Checkout / Mercado Pago
- [ ] Pagamento obrigatório (configurável por tenant)
- [ ] Pagamento parcial (taxa de reserva)
- [ ] Política de reembolso automático

### Notificações WhatsApp
- [ ] Integração com Evolution API ou Twilio
- [ ] Templates de mensagem: confirmação, lembrete, cancelamento
- [ ] Configuração de canal preferido pelo tenant (email, WhatsApp, ambos)

### Personalização de Marca
- [ ] Upload de logo e ícone
- [ ] Seleção de paleta de cores (primária/secundária)
- [ ] Preview em tempo real da booking page

### Dashboard Avançado
- [ ] Taxa de no-show por profissional
- [ ] Taxa de ocupação (slots usados vs disponíveis)
- [ ] Ranking de serviços e profissionais
- [ ] Gráficos temporais (Chart.js ou Chartkick)
- [ ] Exportação CSV dos relatórios

**✅ Entregável:** Plataforma com pagamentos integrados, comunicação via WhatsApp e analytics detalhados.

---

## 🔵 LATER — v2+ (Trimestre 2+)

> **Objetivo:** Escalar para negócios maiores e expandir canais.

### Multi-localização
- [ ] Tenant pode ter múltiplas unidades/filiais
- [ ] Cada unidade tem seus próprios profissionais e horários
- [ ] Dashboard consolidado (cross-location)

### Funcionalidades Avançadas
- [ ] Agendamento recorrente (ex: toda terça às 14h)
- [ ] Lista de espera (waitlist para horários lotados)
- [ ] Avaliações e notas dos clientes (pós-atendimento)
- [ ] App mobile (PWA ou React Native)
- [ ] Integração com Google Calendar (sync bidirecional)
- [ ] API pública para integrações de terceiros
- [ ] Marketplace de profissionais

### Growth & Enterprise
- [ ] Programa de indicação (referral)
- [ ] White-label (marca do cliente, sem menção ao Agenda AI)
- [ ] SSO / SAML para empresas grandes
- [ ] SLA e suporte dedicado

---

## 📈 Métricas de Sucesso do Produto

| Métrica | Meta MVP | Meta v1.1 | Meta v2 |
|---------|----------|-----------|---------|
| Tenants Cadastrados | 50 | 200 | 1.000 |
| Agendamentos/mês (total) | 500 | 5.000 | 50.000 |
| Taxa de No-Show | < 20% | < 10% | < 5% |
| MRR (Monthly Recurring Revenue) | R$ 1.000 | R$ 10.000 | R$ 100.000 |
| Churn Mensal | < 15% | < 8% | < 5% |
| NPS | > 30 | > 50 | > 70 |

---

## 🏁 Próximo Passo

> Feature **Multi-Tenancy + Motor de Agendamento + Gestão de Profissionais** estão prontas para planejamento técnico.
>
> **@Rails Architect**, por favor crie o Implementation Plan para o MVP (Módulos 1-5).
