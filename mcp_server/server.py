#!/usr/bin/env python3
"""
Agenda AI - Servidor MCP em Python
Fornece ferramentas (tools) para integração e cadastro de serviços no sistema Agenda AI.
Compatível com mcp 1.x e 2.x.
"""

import os
import sys
from typing import Optional, Dict, Any
import httpx

# Compatibilidade entre mcp 1.x (FastMCP) e mcp 2.x (MCPServer)
try:
    from mcp.server.fastmcp import FastMCP
    mcp = FastMCP("Agenda AI MCP Server")
except (ImportError, ModuleNotFoundError):
    from mcp.server.mcpserver import MCPServer
    mcp = MCPServer("Agenda AI MCP Server")

# URL base padrão do sistema em produção
DEFAULT_BASE_URL = "https://agenda-ai-4h1p.onrender.com"


def get_base_url() -> str:
    """Retorna a URL base do Agenda AI configurada via ambiente ou o padrão de produção."""
    return os.environ.get("AGENDA_AI_URL", DEFAULT_BASE_URL).rstrip("/")


def get_auth_token(token_override: Optional[str] = None) -> Optional[str]:
    """Obtém o token de autenticação (passado diretamente ou via variável de ambiente)."""
    if token_override and token_override.strip():
        return token_override.strip()
    env_token = os.environ.get("AGENDA_AI_TOKEN", "").strip()
    return env_token if env_token else None


@mcp.tool()
def cadastrar_servico(
    name: str,
    duration_minutes: int,
    price_cents: int = 0,
    price: Optional[float] = None,
    description: str = "",
    currency: str = "BRL",
    active: bool = True,
    token: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Cadastra um novo serviço no sistema de agendamentos Agenda AI.

    Args:
        name: Nome do serviço (ex: "Corte Masculino", "Consulta Inicial", "Manicure").
        duration_minutes: Duração do serviço em minutos (ex: 30, 45, 60).
        price_cents: Preço em centavos (ex: 5000 para R$ 50,00).
        price: Preço em reais no formato decimal (ex: 50.0 ou 75.50). Sobrescreve price_cents se informado.
        description: Descrição detalhada do serviço.
        currency: Moeda utilizada (padrão: "BRL").
        active: Define se o serviço está ativo para novos agendamentos (padrão: True).
        token: Token de autenticação Bearer da API. Se não fornecido, utiliza a variável de ambiente AGENDA_AI_TOKEN.

    Returns:
        Dicionário com o status da operação e os detalhes do serviço cadastrado.
    """
    auth_token = get_auth_token(token)
    if not auth_token:
        return {
            "status": "error",
            "message": (
                "Token de autenticação não fornecido. "
                "Por favor, passe o argumento 'token' ou defina a variável de ambiente AGENDA_AI_TOKEN. "
                "Você também pode gerar um token usando a ferramenta 'gerar_token(email, password)'."
            ),
        }

    base_url = get_base_url()
    endpoint = f"{base_url}/api/v1/services"

    payload: Dict[str, Any] = {
        "service": {
            "name": name.strip(),
            "duration_minutes": int(duration_minutes),
            "description": description.strip() if description else None,
            "currency": currency.strip().upper(),
            "active": bool(active),
        }
    }

    if price is not None:
        payload["service"]["price"] = float(price)
    else:
        payload["service"]["price_cents"] = int(price_cents)

    headers = {
        "Authorization": f"Bearer {auth_token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    try:
        with httpx.Client(timeout=15.0) as client:
            response = client.post(endpoint, json=payload, headers=headers)

            if response.status_code == 201:
                data = response.json()
                service = data.get("service", {})
                return {
                    "status": "success",
                    "message": f"Serviço '{service.get('name')}' cadastrado com sucesso!",
                    "service": service,
                }
            elif response.status_code == 401:
                return {
                    "status": "error",
                    "code": 401,
                    "message": "Token de autenticação inválido ou expirado. Verifique o token e tente novamente.",
                }
            elif response.status_code == 422:
                data = response.json()
                return {
                    "status": "error",
                    "code": 422,
                    "message": "Dados do serviço inválidos.",
                    "errors": data.get("errors", []),
                }
            else:
                return {
                    "status": "error",
                    "code": response.status_code,
                    "message": f"Erro inesperado do servidor ({response.status_code}): {response.text}",
                }
    except httpx.ConnectError:
        return {
            "status": "error",
            "message": f"Falha ao conectar no servidor Agenda AI em {base_url}. Verifique sua conexão ou a URL do sistema.",
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na requisição: {str(e)}",
        }


@mcp.tool()
def gerar_token(email: str, password: str) -> Dict[str, Any]:
    """
    Gera um novo token de API do Agenda AI utilizando email e senha do usuário cadastrado.

    Args:
        email: Email de login do usuário administrador/gerente.
        password: Senha do usuário.

    Returns:
        Dicionário contendo o token de autenticação gerado e informações do tenant.
    """
    base_url = get_base_url()
    endpoint = f"{base_url}/api/v1/auth/token"

    payload = {
        "email": email.strip().lower(),
        "password": password,
    }

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    try:
        with httpx.Client(timeout=15.0) as client:
            response = client.post(endpoint, json=payload, headers=headers)

            if response.status_code == 200:
                data = response.json()
                token = data.get("token")
                user = data.get("user", {})
                tenant = data.get("tenant", {})
                return {
                    "status": "success",
                    "message": f"Token gerado com sucesso para {user.get('name')} ({tenant.get('name')}).",
                    "token": token,
                    "user": user,
                    "tenant": tenant,
                    "instruction": "Você pode exportar este token como 'export AGENDA_AI_TOKEN=...' ou passá-lo diretamente nas chamadas da tool 'cadastrar_servico'.",
                }
            elif response.status_code == 401:
                return {
                    "status": "error",
                    "code": 401,
                    "message": "Email ou senha incorretos.",
                }
            else:
                return {
                    "status": "error",
                    "code": response.status_code,
                    "message": f"Erro ao gerar token ({response.status_code}): {response.text}",
                }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Erro na conexão com {base_url}: {str(e)}",
        }


if __name__ == "__main__":
    # Executa o servidor MCP via stdio
    mcp.run()
