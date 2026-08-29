# Servidor MCP Agenda AI (Python)

Servidor oficial do **Model Context Protocol (MCP)** em Python para integração com a plataforma de agendamentos **Agenda AI**.

## 🚀 Funcionalidades

- **`cadastrar_servico`**: Ferramenta (tool) para cadastrar novos serviços no sistema (nome, duração, preço, descrição, etc.).
- **`gerar_token`**: Ferramenta auxiliar para autenticar e obter o token de acesso à API informando email e senha.

---

## 🛠 Pré-requisitos

- Python 3.10+ ou gerenciador [uv](https://docs.astral.sh/uv/) (recomendado)

---

## 📦 Instalação e Execução

### Opção 1: Executando com `uv` (Recomendado)

```bash
# Executa diretamente sem necessidade de criar virtualenv manualmente:
uv run --with mcp --with httpx python mcp_server/server.py
```

### Opção 2: Com `pip` e Virtualenv

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r mcp_server/requirements.txt

python mcp_server/server.py
```

---

## ⚙️ Configuração no seu Cliente MCP

### 1. Antigravity IDE / Claude Desktop / Cursor

Adicione ao seu arquivo de configuração MCP (`mcp_config.json` ou `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "agenda-ai": {
      "command": "uv",
      "args": [
        "run",
        "--with",
        "mcp",
        "--with",
        "httpx",
        "python",
        "/caminho/absoluto/para/agenda-ai/mcp_server/server.py"
      ],
      "env": {
        "AGENDA_AI_URL": "https://agenda-ai-4h1p.onrender.com",
        "AGENDA_AI_TOKEN": "SEU_TOKEN_AQUI"
      }
    }
  }
}
```

---

## 🔧 Ferramentas Disponíveis

### `cadastrar_servico`
Cadastra um novo serviço para o seu estabelecimento:

**Parâmetros:**
- `name` *(obrigatório)*: Nome do serviço (ex: `"Corte Degrade"`)
- `duration_minutes` *(obrigatório)*: Duração em minutos (ex: `30`)
- `price` *(opcional)*: Valor em reais (ex: `45.0` ou `60.00`)
- `price_cents` *(opcional)*: Valor em centavos (ex: `4500`)
- `description` *(opcional)*: Detalhes do serviço
- `currency` *(opcional, padrão: "BRL")*
- `active` *(opcional, padrão: true)*
- `token` *(opcional se definido em AGENDA_AI_TOKEN)*

### `gerar_token`
Gera o token de API caso ainda não possua:

**Parâmetros:**
- `email`: Email cadastrado na plataforma
- `password`: Senha da conta
