# omni-img

CLI pra listar e testar modelos de geração de imagem do OmniRoute.

Pensado pra rodar dentro do Claude Code CLI como ferramenta companion — você configura a URL/key do OmniRoute uma vez, lista modelos, escolhe na ordem, e roda testes pra descobrir qual provider/credential tá funcional.

## Instalacao

```bash
git clone https://github.com/inovalabsx/omni-img.git
cd omni-img
bash install.sh
```

Requer Python 3.11+ (usa `tomllib` stdlib). Sem deps externas.

## Uso

```bash
# 1. Configurar (uma vez)
omni-img config https://lua.ominiroute.inovalabx.com.br sk-xxx

# 2. Ver modelos disponiveis (marca image-capable com [IMG])
omni-img models

# 3. Selecionar modelos na ordem (interativo)
omni-img pick
# Escolha (numeros separados por virgula, na ordem desejada): 3,1,5,2

# 4. Testar credenciais gerando 1 imagem (round-robin na lista)
omni-img test "um gato astronauta em pixel art"

# 5. Ver config atual
omni-img show
```

## Config

Ordem de prioridade:
1. **env vars**: `OMNI_BASE_URL`, `OMNI_API_KEY`
2. **arquivo**: `~/.config/omni-img/config.toml`

Formato do arquivo:
```toml
base_url = "https://ominiroute.example.com"
api_key = "sk-xxx"
```

## Arquivos gerados

- `~/.config/omni-img/config.toml` — credenciais (nunca comitar)
- `~/.config/omni-img/selected.toml` — modelos selecionados na ordem

## Subcomandos

| Comando | O que faz |
|---|---|
| `omni-img config URL KEY` | Salva credenciais |
| `omni-img models` | Lista modelos (marca image-capable) |
| `omni-img pick` | Selecao interativa (numeros, ordem) |
| `omni-img test [PROMPT]` | Gera 1 imagem (tenta cada modelo selecionado na ordem) |
| `omni-img show` | Mostra config atual |

## Deteccao de image-capable

Heuristica por keyword no `id` do modelo ou nos metadados:
- `image`, `imagen`, `dall-e`, `dalle`, `sd`, `flux`, `sdxl`, `midjourney`, `kandinsky`, `playground`, `gemini-image`

Se quiser adicionar mais keywords, edite a tupla `IMAGE_KEYWORDS` no script.

## Integracao com Claude Code

Invoca via Bash tool. Claude Code consome stdout JSON cru.

```bash
# Em qualquer sessa do Claude Code:
omni-img models              # lista modelos
omni-img test "prompt"       # testa
```

## Fallback round-robin

`omni-img test` tenta cada modelo da lista `selected.toml` em ordem ate um funcionar. Util pra descobrir qual provider/credential ta saudavel sem hardcode.

## Filosofia

- **Sem hardcode** — toda config vem de env vars ou arquivo TOML
- **Sem deps externas** — stdlib Python only
- **Sem auto-update** — você controla quando atualizar (clone/pull manual)
- **Sem telemetria** — zero network calls alem do OmniRoute que voce configurou
- **Stack-friendly** — feito pra coexistir com `codegraph`, `claude-router`, `omniroute-image`, etc

## License

MIT © 2026 inovalabsx
