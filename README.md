# 💈 Agenda AI — Sistema Multi-Tenant de Agendamento Inteligente

Sistema SaaS completo de agendamento online com multi-tenancy nativo por subdomínio/path, motor inteligente de cálculo de disponibilidade, prevenção de *double-booking* com locking pessimístico, notificações assíncronas via Solid Queue, dashboard de métricas e interface pública mobile-first.

---

## 🛠️ Stack Tecnológico

- **Backend:** Ruby 3.4.10, Rails 8.1.3.1
- **Arquitetura Multi-Tenant:** `acts_as_tenant` (escopo automático por tenant `/:tenant_slug`)
- **Frontend & Reatividade:** Hotwire (Turbo Drive, Turbo Frames, Stimulus) + Tailwind CSS 4
- **Banco de Dados:** SQLite3 (dev/test) / PostgreSQL (prod com suporte a pgvector para agentes de IA)
- **Background Jobs & Filas:** Solid Queue (Rails 8 nativo)
- **Cache & WebSockets:** Solid Cache & Solid Cable
- **Autenticação:** Devise com bcrypt e identificadores UUID
- **Deploy & Infra:** Docker, Kamal 2

---

## 🚀 Como Executar Localmente

### 1. Pré-requisitos
- Ruby 3.4.x instalado (via `mise`, `asdf` ou `rbenv`)
- SQLite3 e dependências básicas de compilação

### 2. Instalação e Preparação do Banco
```bash
# Instalar dependências
bundle install

# Executar migrações do banco
bin/rails db:migrate

# Popular banco com o dataset completo de demonstração
bin/rails db:seed

# Compilar assets do Tailwind CSS
bin/rails tailwindcss:build
```

### 3. Iniciar o Servidor
```bash
bin/rails server -b 0.0.0.0 -p 3000
```
Acesse a aplicação em `http://localhost:3000`.

---

## 🔑 Credenciais de Demonstração

| Perfil | URL | Login | Senha |
| :--- | :--- | :--- | :--- |
| **Landing Page SaaS** | `http://localhost:3000/` | — | — |
| **Painel Admin do Salão** | `http://localhost:3000/salao-demo/admin` | `admin@demo.com` | `password123` |
| **Página Pública do Salão** | `http://localhost:3000/salao-demo/public/tenant_page` | — | — |
| **Agendamento Online Público** | `http://localhost:3000/salao-demo/public/bookings` | — | — |

---

## 📦 Estrutura dos Módulos Entregues (Sprints 1 a 7)

```
app/
├── controllers/
│   ├── admin/
│   │   ├── appointments_controller.rb  # Gestão de atendimentos, conclusão, no-show e cancelamentos
│   │   ├── availabilities_controller.rb # Grade de horários semanais dos profissionais
│   │   ├── dashboard_controller.rb     # Métricas, KPIs de receita e gráficos de distribuição
│   │   ├── professionals_controller.rb # CRUD e alocação de serviços por profissional
│   │   ├── services_controller.rb      # CRUD de serviços com duração e preços
│   │   ├── settings_controller.rb      # Configurações de branding, lembretes e políticas
│   │   └── time_blocks_controller.rb   # Bloqueios pontuais de agenda (férias, consultas)
│   └── public/
│       ├── appointments_controller.rb  # Autoatendimento e cancelamento pelo cliente
│       ├── bookings_controller.rb      # Fluxo multi-step público de agendamento online
│       ├── slots_controller.rb         # API de consulta de slots disponíveis (JSON & HTML)
│       └── tenant_pages_controller.rb  # Landing page pública institucional do estabelecimento
├── jobs/
│   ├── mark_no_show_job.rb             # Marcação automática diária de faltas
│   └── send_notification_job.rb        # Disparo assíncrono de notificações com retry
├── mailers/
│   └── appointment_mailer.rb           # Emails de confirmação, lembretes 24h/2h e avisos
├── models/
│   ├── appointment.rb                  # Agendamentos com optimistic locking e enums
│   ├── availability.rb                 # Janelas de atendimento por dia da semana
│   ├── client.rb                       # Clientes com histórico de no-show e atendimentos
│   ├── notification.rb                 # Registro e rastreio de notificações multicanal
│   ├── professional.rb                 # Profissionais com buffer_minutes
│   ├── professional_service.rb         # Junção n:n profissional x serviço
│   ├── service.rb                      # Serviços com conversão monetária
│   ├── tenant.rb                       # Empresas cadastradas (slug único)
│   ├── tenant_setting.rb               # Políticas e preferências por tenant
│   ├── time_block.rb                   # Bloqueios parciais e de dia inteiro
│   └── user.rb                         # Usuários autenticados via Devise
└── services/
    ├── analytics/
    │   └── dashboard_metrics.rb        # Cálculo de KPIs, faturamento e taxas de no-show
    ├── appointments/
    │   ├── canceller.rb                # Cancelamento validando políticas do tenant
    │   ├── creator.rb                  # Criação com lock pessimístico (prevenção de double-booking)
    │   └── rescheduler.rb              # Reagendamento seguro com checagem de conflitos
    ├── notifications/
    │   ├── dispatcher.rb               # Orquestrador de canais de notificação
    │   └── reminder_scheduler.rb       # Agendamento de lembretes automáticos
    ├── onboarding/
    │   └── tenant_setup.rb             # Criação transacional de tenant, admin e settings
    └── slots/
        ├── availability_calculator.rb  # Motor central de cálculo de horários livres
        └── slot_finder.rb              # Consolidador de slots por profissional ou equipe
```

---

## 🧪 Testes Automatizados

O projeto conta com **178 testes automatizados no RSpec** com cobertura completa de models, services, jobs, mailers e controllers:

```bash
# Executar todos os testes
bundle exec rspec

# Verificar conformidade de código com RuboCop
bundle exec rubocop
```

---

## 📄 Licença
Propriedade do projeto **Agenda AI** — Todos os direitos reservados.
