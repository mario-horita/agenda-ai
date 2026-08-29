# Feature Specs — Agenda AI

> Especificações detalhadas das funcionalidades agrupadas por domínio.
> Cada feature referencia o JTBD que ela resolve.

---

## 📐 Arquitetura Macro

- **Stack:** Ruby on Rails 8 + Hotwire (Turbo + Stimulus)
- **Multi-tenancy:** Baseada em subdomínio ou slug (ex: `meusalao.agenda-ai.com.br`)
- **Billing:** Assinatura mensal com 3 planos (Starter, Pro, Enterprise)
- **Notificações:** Email (ActionMailer/Postmark) + WhatsApp (Evolution API ou Twilio)
- **Pagamentos:** Stripe e/ou Mercado Pago

---

## 🔷 Módulo 1: Multi-Tenancy & Onboarding

**Resolve:** J1, J7
**Prioridade:** 🔴 Crítica (MVP)

### Features:
| Feature | Descrição |
|---------|-----------|
| Cadastro do Tenant | Signup do dono do negócio: nome da empresa, email, slug/subdomínio |
| Setup Wizard | Passo-a-passo guiado: criar primeiro profissional, primeiro serviço, definir horários |
| Página Pública do Tenant | Landing page com serviços, profissionais, e botão "Agendar Agora" |
| Personalização de Marca | Upload de logo, seleção de cores primárias/secundárias |
| Isolamento de Dados | Cada tenant vê apenas seus dados (scoped queries via `acts_as_tenant` ou `current_tenant`) |

### Critérios de Aceite:
- [ ] Tenant consegue se cadastrar e acessar o painel em menos de 2 minutos
- [ ] Dados de um tenant nunca aparecem para outro tenant
- [ ] Página pública é acessível sem login e é responsiva (mobile-first)

---

## 🔷 Módulo 2: Gestão de Profissionais & Serviços

**Resolve:** J1, J4
**Prioridade:** 🔴 Crítica (MVP)

### Features:
| Feature | Descrição |
|---------|-----------|
| CRUD de Profissionais | Nome, avatar, bio, especialidades, status (ativo/inativo) |
| CRUD de Serviços | Nome, descrição, duração, preço, profissionais vinculados |
| Disponibilidade Semanal | Configuração de horários por dia da semana (ex: Seg 09:00-18:00) |
| Bloqueio de Horários | Profissional pode bloquear datas/horários específicos (férias, folgas) |
| Intervalo entre Atendimentos | Buffer configurável entre agendamentos (ex: 15 min) |

### Critérios de Aceite:
- [ ] Profissional consegue configurar sua disponibilidade sem suporte
- [ ] Serviços são vinculados a 1 ou mais profissionais
- [ ] Horários bloqueados não aparecem como disponíveis na página pública

---

## 🔷 Módulo 3: Motor de Agendamento

**Resolve:** J3
**Prioridade:** 🔴 Crítica (MVP)

### Features:
| Feature | Descrição |
|---------|-----------|
| Seleção de Serviço | Cliente escolhe o serviço desejado |
| Seleção de Profissional | Cliente escolhe profissional ou aceita "Qualquer disponível" |
| Calendário de Slots | Exibe dias e horários disponíveis em tempo real |
| Dados do Cliente | Nome, telefone, email (sem necessidade de criar conta) |
| Confirmação Instantânea | Agendamento confirmado imediatamente com resumo |
| Prevenção de Conflitos | Verificação atômica: dois clientes não podem agendar o mesmo slot |
| Cancelamento/Reagendamento | Cliente pode cancelar ou reagendar até X horas antes (configurável) |

### Critérios de Aceite:
- [ ] Fluxo de agendamento completo em ≤ 4 cliques
- [ ] Slots refletem disponibilidade real em tempo real (Turbo Streams)
- [ ] Não é possível fazer double-booking (lock otimístico ou pessimístico)
- [ ] Funciona perfeitamente em telas de celular

---

## 🔷 Módulo 4: Notificações & Lembretes

**Resolve:** J2
**Prioridade:** 🔴 Crítica (MVP)

### Features:
| Feature | Descrição |
|---------|-----------|
| Email de Confirmação | Enviado ao cliente e ao profissional após agendamento |
| Lembrete Automático | Email/WhatsApp X horas antes do agendamento (configurável: 24h, 2h) |
| Notificação de Cancelamento | Aviso automático quando cliente cancela |
| Notificação de Reagendamento | Aviso quando horário é alterado |
| Preferência de Canal | Tenant configura se quer email, WhatsApp ou ambos |

### Critérios de Aceite:
- [ ] Lembretes são enviados via jobs assíncronos (Solid Queue / Sidekiq)
- [ ] WhatsApp funciona via API (Evolution API ou Twilio)
- [ ] Cliente recebe lembrete 24h e 2h antes (configurável pelo admin)

---

## 🔷 Módulo 5: Dashboard & Métricas

**Resolve:** J5
**Prioridade:** 🟡 Alta (MVP)

### Features:
| Feature | Descrição |
|---------|-----------|
| Visão Geral | Total de agendamentos (hoje, semana, mês), faturamento estimado |
| Taxa de No-Show | % de clientes que não compareceram |
| Taxa de Ocupação | % de slots preenchidos vs disponíveis por profissional |
| Ranking de Serviços | Serviços mais agendados |
| Ranking de Profissionais | Profissionais com maior demanda |
| Gráficos Temporais | Evolução de agendamentos e faturamento ao longo do tempo |

### Critérios de Aceite:
- [ ] Dashboard carrega em < 2 segundos
- [ ] Dados são filtráveis por período (hoje, 7d, 30d, custom)
- [ ] Métricas atualizam em tempo real via Turbo Streams

---

## 🔷 Módulo 6: Pagamento Online

**Resolve:** J6
**Prioridade:** 🟡 Alta (Pós-MVP v1.1)

### Features:
| Feature | Descrição |
|---------|-----------|
| Checkout no Agendamento | Opção de pagar no momento do agendamento |
| Pagamento Parcial | Cobrar taxa de reserva (ex: 30% antecipado) |
| Gateway de Pagamento | Integração com Stripe e/ou Mercado Pago |
| Política de Reembolso | Reembolso automático se cancelado dentro da janela permitida |
| Relatório Financeiro | Extrato de recebimentos por período |

### Critérios de Aceite:
- [ ] Checkout funciona via Stripe Checkout ou Mercado Pago Checkout Pro
- [ ] Tenant pode ativar/desativar pagamento obrigatório
- [ ] Reembolso automático respeita política de cancelamento configurada

---

## 🔷 Módulo 7: Planos & Billing (SaaS)

**Resolve:** Monetização
**Prioridade:** 🟡 Alta (MVP)

### Planos:

| Recurso | Starter (Grátis) | Pro (R$79/mês) | Enterprise (R$199/mês) |
|---------|:-:|:-:|:-:|
| Profissionais | 1 | Até 10 | Ilimitado |
| Serviços | 5 | Ilimitado | Ilimitado |
| Agendamentos/mês | 50 | Ilimitado | Ilimitado |
| Notificações Email | ✅ | ✅ | ✅ |
| Notificações WhatsApp | ❌ | ✅ | ✅ |
| Pagamento Online | ❌ | ✅ | ✅ |
| Dashboard Avançado | Básico | Completo | Completo |
| Personalização de Marca | ❌ | ✅ | ✅ |
| Multi-localização | ❌ | ❌ | ✅ |
| Suporte | Comunidade | Email | Prioritário |

### Critérios de Aceite:
- [ ] Limites são enforced em tempo real (ex: bloqueia criação do 6º serviço no Starter)
- [ ] Upgrade/Downgrade é self-service
- [ ] Trial de 14 dias do Pro para novos tenants
