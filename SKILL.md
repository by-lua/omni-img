---
name: omni-img
description: Generate and edit images via OmniRoute using free tiers (Gemini, ChatGPT Pro via Codex). Use when the user asks for image generation, image editing, or wants to test which image models work with their OmniRoute credentials.
---

# omni-img — Generate and Edit Images via OmniRoute

CLI tool that talks to your local OmniRoute instance and generates/edits images using the free tiers of Gemini and ChatGPT Pro (via Codex). Stdlib-only Python 3.11+.

## When to use this skill

- User asks to generate an image ("gera uma imagem de...", "make an image of...")
- User asks to edit/transform an existing image ("coloca óculos de sol nessa foto", "transforma em pixel art")
- User wants to know which image models work with their OmniRoute
- User wants to test image generation without paying for API

## Installation

```bash
git clone https://github.com/by-lua/omni-img.git
cd omni-img
bash install.sh
omni-img config https://SUA-OMNIROUTE sk-xxx
```

`config` stores base_url + api_key in `~/.config/omni-img/config.toml` (no hardcode). You can also use env vars `OMNI_BASE_URL` and `OMNI_API_KEY`.

## Subcommands

### `models`

List all image-capable models from `GET /v1/images/generations` (OmniRoute canonical endpoint).

```bash
omni-img models
```

Returns model id, provider, and supported sizes.

### `pick`

Interactively choose models in fallback order. Saves to `~/.config/omni-img/selected.toml`.

```bash
omni-img pick
```

The fallback chain is what `generate` and `edit` use — first model is tried, falls back to next on error.

### `generate <prompt>`

Generate an image, save to `./out/img_<model>_<timestamp>.png`.

```bash
omni-img generate "uma abacaxi sorridente no espaco, pixel art"
omni-img generate "um gato astronauta" --size 1024x1024
omni-img generate "paisagem montanhosa" --all --n 4
```

**Flags:**
- `--model <id>` — force specific model
- `--all` — try ALL models in fallback chain, save what works
- `--size <WxH>` — default `1024x1024`
- `--n <count>` — number of variations, default `1`

### `edit <image> <prompt>`

Edit an existing image via `POST /v1/images/edits` (multipart upload).

```bash
omni-img edit foto.png "coloca um óculos de sol"
omni-img edit foto.png "transforma em pixel art" --all
omni-img edit https://exemplo.com/foto.jpg "pintura a óleo" --model codex/gpt-5.5
```

**Image source** (positional arg):
- Local path: `./foto.png`
- HTTP(S) URL: `https://exemplo.com/foto.jpg`
- Data URL: `data:image/png;base64,...`

**Flags:** same as `generate` (--model, --all, --size).

### `test`

Shortcut for `generate` with default prompt — use to validate credentials.

```bash
omni-img test
```

### `show`

Show current config and fallback chain.

```bash
omni-img show
```

### `config <base_url> <api_key>`

Save credentials to `~/.config/omni-img/config.toml`. Run once.

```bash
omni-img config https://lua.ominiroute.inovalabx.com.br sk-xxx
```

## Compatible models (probe 2026-06-20, 145 tested)

Only **2 models** work out of the box with default credentials:

| Model | Provider | Time | Notes |
|---|---|---|---|
| `codex/gpt-5.5` | ChatGPT Pro (Codex) | ~18s | High quality, 1-3 MB output |
| `antigravity/gemini-3.1-flash-image` | Google free | ~10s | Smaller output ~775 KB |

**105 models fail** with "No credentials for image provider" — to enable:
- `kie` (36) — add KIE.ai API key in OmniRoute panel
- `fal-ai` (12) — add fal.ai key
- `black-forest-labs` (9) — Flux official, add key
- `pollinations` (8) — FREE, no key needed, just enable in panel
- `openrouter` (7) — add OpenRouter key
- `stability-ai` (6) — Stability AI key
- `fireworks` (5), `recraft` (4), `openai` (3), `nanogpt` (3), `xai` (2), etc.

**34 models are image-to-image only** (require input image, use `edit` not `generate`):
- `together/*` (10)
- `stability-ai/erase|inpaint|outpaint|remove-background|...` (7)
- `kie/*-edit` and `kie/*-image-to-image` (~20)

## Recommended fallback chain

Edit `~/.config/omni-img/selected.toml`:

```toml
model_1 = "codex/gpt-5.5"
model_2 = "antigravity/gemini-3.1-flash-image"
```

`codex/gpt-5.5` first (highest quality via ChatGPT Pro). `antigravity/gemini-3.1-flash-image` as backup (free Google).

## Endpoints used

| Method | Path | Body |
|---|---|---|
| GET | `/v1/images/generations` | — (list models) |
| POST | `/v1/images/generations` | `{model, prompt, n?, size?}` (generate) |
| POST | `/v1/images/edits` | multipart: `image` + `prompt` + `model` + `size` (edit) |

Reference: https://github.com/diegosouzapw/OmniRoute/tree/main/src/app/api/v1/images

## Files

| Path | Purpose |
|---|---|
| `~/.config/omni-img/config.toml` | base_url + api_key |
| `~/.config/omni-img/selected.toml` | fallback chain order |
| `./out/img_*.{png,jpg,webp}` | generated images |
| `./out/edit_*.{png,jpg,webp}` | edited images |

## Common patterns for agents

### Generate and return path

```bash
omni-img generate "um gato astronauta flutuando em saturno" --size 1024x1024
# Output:
#   saved: /path/to/out/img_codex_gpt-5.5_20260620_120000_1.png
```

Read the path from stdout and use `MEDIA:/path/to/file.png` to send to user.

### Edit user-provided image

When user attaches an image (Telegram photo), download it first, then:

```bash
omni-img edit /tmp/user_photo.jpg "transforma em pintura a oleo"
```

### Pick model from list

```bash
omni-img models | head -20  # see what's available
omni-img pick                # interactive selection
```

Or edit `selected.toml` directly to hardcode the chain:

```toml
model_1 = "codex/gpt-5.5"
model_2 = "antigravity/gemini-3.1-flash-image"
```

## Pitfalls

- **No image returned but HTTP 200** — some providers return empty `data: []`. The CLI prints the raw response to help debug.
- **HTTP 502/504** — upstream is overloaded. `codex/gpt-5.5` sometimes takes 30s+, retry with longer timeout.
- **HTTP 400 "Image input is required"** — model is image-to-image only. Use `edit` instead of `generate`.
- **HTTP 400 "No credentials"** — model needs provider API key added in OmniRoute panel.
- **Codex can be slow** — 18s is normal for `codex/gpt-5.5`. Fallback to Gemini kicks in automatically if it times out (>30s).

## License

MIT
