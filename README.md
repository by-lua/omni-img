# omni-img

Gera e edita imagens via [OmniRoute](https://github.com/diegosouzapw/OmniRoute) usando os **limites gratuitos** das contas que você já tem (Gemini, GPT, etc) — sem pagar API cara.

CLI único, **stdlib-only** (Python 3.11+, sem `pip install`), pensado pra rodar dentro do **Claude Code** ou qualquer terminal.

## O que faz

- Lista os modelos image-capable do seu OmniRoute (`omni-img models`)
- Você escolhe a ordem de preferência e salva (`omni-img pick`)
- **Gera imagens** reais via `/v1/images/generations` e salva em `./out/` (`omni-img generate "um gato"`)
- **Edita imagens** existentes via `/v1/images/edits` (multipart + prompt) e salva em `./out/` (`omni-img edit foto.png "coloca óculos de sol"`)
- Se um modelo der rate-limit (HTTP 429) ou erro, cai pro próximo da lista automaticamente
- Sem hardcode: URL base e API key ficam em `~/.config/omni-img/config.toml` (ou env vars)

## Pré-requisito

Você precisa ter o **OmniRoute rodando** e configurado com suas contas (Gemini, GPT, etc). Sem isso não tem como gerar nada.

→ https://github.com/diegosouzapw/OmniRoute

## Instalação

```bash
git clone https://github.com/by-lua/omni-img.git
cd omni-img
bash install.sh
```

`install.sh` copia `omni-img` pra `/usr/local/bin/` (com `sudo` se precisar) e cria `~/.config/omni-img/`.

## Configuração (uma vez)

```bash
omni-img config https://sua-ominiroute.com.br sk-xxx
```

Ou via env vars (útil pra CI/cron/Claude Code):

```bash
export OMNI_BASE_URL="https://sua-ominiroute.com.br"
export OMNI_API_KEY="sk-xxx"
```

## Uso

### 1. Ver modelos disponíveis

```bash
omni-img models
```

Lista os modelos do endpoint canônico do OmniRoute (`GET /v1/images/generations`) e mostra `owned_by` + `supported_sizes`.

### 2. Escolher a ordem de fallback

```bash
omni-img pick
```

Mostra os modelos image-capable, você digita os números na ordem que quer tentar. Ex: `1,3,2` significa "tenta o 1, se falhar tenta o 3, depois o 2". Salvo em `~/.config/omni-img/selected.toml`.

### 3. Gerar imagem

```bash
omni-img generate "um gato astronauta flutuando em saturno, pintura digital"
```

Vai:
1. Tentar o primeiro modelo da sua lista
2. Se der rate-limit (429) ou erro, cair pro próximo automaticamente
3. Salvar a imagem em `./out/img_<modelo>_<timestamp>.png`
4. Imprimir o caminho do arquivo

#### Opções do generate

```bash
omni-img generate "prompt" --model gemini-2.5-flash-image   # força um modelo
omni-img generate "prompt" --all                            # tenta TODOS, salva o que funcionar
omni-img generate "prompt" --size 512x512                   # tamanho custom
omni-img generate "prompt" --n 4                            # 4 variações
omni-img generate "prompt" --all --size 1024x1024 --n 2
```

### 4. Editar imagem existente

```bash
omni-img edit foto.png "coloca um óculos de sol e fundo de praia"
omni-img edit foto.png "transforma em pixel art" --all
omni-img edit https://exemplo.com/foto.jpg "pintura a óleo" --model gpt-image-1
```

A imagem pode ser:
- Caminho local (`./foto.png`)
- URL `http://` ou `https://`
- Data URL (`data:image/png;base64,...`)

Funciona com o mesmo fallback chain do `generate`.

### Test (atalho)

```bash
omni-img test
```

Mesma coisa que `generate` com prompt default — bom pra checar se credenciais tão funcionando.

### Ver config atual

```bash
omni-img show
```

## Arquivos

| Arquivo | O quê |
|---|---|
| `~/.config/omni-img/config.toml` | base_url + api_key (criado pelo `config`) |
| `~/.config/omni-img/selected.toml` | ordem de fallback dos modelos (criado pelo `pick`) |
| `./out/img_*.{png,jpg,webp}` | imagens geradas (criado pelo `generate`) |
| `./out/edit_*.{png,jpg,webp}` | imagens editadas (criado pelo `edit`) |

## Endpoints OmniRoute usados

| Verbo | Path | O quê |
|---|---|---|
| `GET` | `/v1/images/generations` | Lista modelos de imagem (canônico) |
| `POST` | `/v1/images/generations` | Gera imagem (`{model, prompt, n?, size?}`) |
| `POST` | `/v1/images/edits` | Edita imagem (multipart: `image`, `prompt`, `model`, `size`) |

Ref: https://github.com/diegosouzapw/OmniRoute/tree/main/src/app/api/v1/images

## Por que existe?

Gemini, GPT e outros têm **tiers gratuitos generosos** mas a API direta cobra caro e exige múltiplas contas/keys. O **OmniRoute** unifica tudo num único endpoint OpenAI-compatible. Este CLI te dá uma interface simples pra:

1. Listar modelos de imagem do OmniRoute
2. Escolher a ordem de fallback (Gemini primeiro, GPT segundo, etc)
3. Gerar/editar com retry automático quando um modelo tá rate-limited

Tudo sem hardcode — URL e key configuráveis, sem dependências externas (só stdlib Python).

## Limitações conhecidas

- Requer OmniRoute com provider de imagem configurado
- `edit` só funciona com providers que suportam `/v1/images/edits` (GPT-Image, Gemini-Nano-Banana, etc)
- Sem streaming (gera 1 imagem por vez)
- Sem máscara explícita por enquanto — passa o prompt de edição

## Modelos compatíveis (probe real 2026-06-20)

Probei todos os **145 modelos image-capable** do OmniRoute real. Resultado:

| Status | Count | O quê |
|---|---|---|
| OK | 2 | `codex/gpt-5.5`, `antigravity/gemini-3.1-flash-image` |
| NO_CRED | 105 | Sem credencial configurada (kie, fal-ai, openrouter, pollinations, ...) |
| BAD_REQ | 34 | Modelos image-to-image (exigem imagem de entrada) |
| UPSTREAM | 5 | Timeout/erro upstream transitório |

**Top providers sem credencial** (ative no painel do OmniRoute se quiser usar):
- `kie` (36 modelos) — text-to-image + image-edit via KIE.ai
- `fal-ai` (12) — Flux, Nano-Banana, Recraft, Stable Diffusion
- `black-forest-labs` (9) — Flux oficial
- `pollinations` (8) — sem key necessária, free
- `openrouter` (7) — Gemini/Flux via OpenRouter
- `stability-ai` (6) — SD3.5, inpaint, outpaint, erase
- `fireworks` (5) — Flux Kontext
- `recraft` (4), `openai` (3), `nanogpt` (3), `xai` (2), `nanobanana` (2), `leonardo` (2), `ideogram` (2), `chatgpt-web` (1), `nebius` (1), `hyperbolic` (1), `haiper` (1)

**Modelos image-to-image** (precisam de imagem de entrada, não funcionam com `generate`):
- `together/*` (10 modelos: FLUX, Qwen, Gemini via Together AI)
- `stability-ai/erase|inpaint|outpaint|remove-background|search-and-replace|search-and-recolor|replace-background-and-relight` (7)
- `kie/*-edit` e `kie/*-image-to-image` (~20)

Use o subcomando `edit` pra esses.

## Licença

MIT
