# ai-containers

Rode um modelo de IA (LLM) local, com uma interface de chat tipo ChatGPT, usando só Docker. Sem mandar nada pra nuvem, sem custo de API.

Funciona em **Linux, Windows e Mac**. Por padrão roda na CPU (funciona em qualquer máquina); em Linux com GPU Intel ou AMD dá pra acelerar via Vulkan.

## Qual modelo rodar

| Sua GPU | Modelo | Download |
|---|---|---|
| Sem GPU (só CPU) | Qwen2.5 3B | ~2,1 GB |
| 4-6 GB de VRAM | Qwen2.5 3B | ~2,1 GB |
| 8 GB de VRAM | Qwen2.5 7B | ~4,7 GB |
| 12 GB de VRAM | Qwen2.5 14B | ~9 GB |
| 24 GB+ de VRAM | Qwen2.5 32B | ~20 GB |

Esses valores são só o tamanho do modelo — a placa também precisa de uma margem extra de VRAM pra manter a conversa (contexto). Na dúvida, escolha o modelo de baixo na tabela. O `start.sh` (próxima seção) já pergunta isso e monta tudo certo.

## Pré-requisitos

- **Docker** instalado e rodando.
  - Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Linux: [Docker Engine](https://docs.docker.com/engine/install/)
- Uns 6GB livres em disco (modelo + imagens).

## Como rodar

1. Clone o repositório:
   ```bash
   git clone <url-deste-repositorio>
   cd ai-containers
   ```

2. Se for usar GPU Intel ou AMD no Linux, instale os drivers Vulkan primeiro (Ubuntu/Debian):
   ```bash
   sudo apt install -y mesa-vulkan-drivers vulkan-tools libvulkan1
   ```

3. Rode o script de setup — ele pergunta qual modelo você quer e se tem GPU, e já sobe tudo:
   ```bash
   ./start.sh
   ```
   (Windows: rode pelo Git Bash ou WSL, que já vêm junto com o Docker Desktop.)

4. Aguarde o download do modelo (primeira vez só). Acompanhe com:
   ```bash
   docker compose logs -f llama-server
   ```
   Quando aparecer `model loaded` e `listening on http://0.0.0.0:8080`, está pronto.

5. Abra `http://localhost:3000` no navegador, crie sua conta local (a primeira conta criada vira admin) e comece a conversar. O modelo já aparece disponível pra seleção.

Pronto — sem chave de API, sem conta em serviço nenhum, tudo roda na sua máquina.

> NVIDIA no Linux ou GPU no Windows/WSL2 não estão configurados aqui — dá pra rodar, mas exige um override de compose diferente (nvidia-container-toolkit). Fora do escopo deste repo por enquanto.

<details>
<summary>Quer rodar sem o script, na mão?</summary>

Defina `LLAMA_MODEL` no `.env` primeiro (veja [Trocar de modelo](#trocar-de-modelo)), depois:

- Sem GPU:
  ```bash
  docker compose up -d
  ```
- Com GPU:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
  ```

</details>

## Como verificar se está usando a GPU

1. Confirme que o Vulkan enxerga sua GPU:
   ```bash
   docker run --rm --device /dev/dri ghcr.io/ggml-org/llama.cpp:server-vulkan --list-devices
   ```
   Deve aparecer algo como `Vulkan0: Intel(R) Arc(tm) B580 Graphics (BMG G21) (12216 MiB, 1824 MiB free)` — com o nome da sua placa. Se não listar nada, ou só aparecer `llvmpipe` (renderizador por software), a GPU não está sendo enxergada.

2. Veja o uso da GPU em tempo real durante uma conversa:
   - Intel: `sudo apt install -y intel-gpu-tools` e depois `sudo intel_gpu_top`
   - AMD: `sudo apt install -y radeontop` e depois `sudo radeontop`

   Manda uma mensagem no chat e observe o uso subir.

3. Alternativa sem instalar nada: monitore a CPU com `top` durante uma conversa — se ficar praticamente ociosa, a inferência está rodando na GPU. É indireto, mas serve como indício rápido.

## Trocar de modelo

Mais fácil: rode `./start.sh` de novo e escolha outro modelo na lista.

Na mão: edite (ou crie) um arquivo `.env` a partir do `.env.example`:

```bash
cp .env.example .env
```

E mude a variável `LLAMA_MODEL` pra qualquer repositório GGUF do Hugging Face, no formato `repositorio:quant`, por exemplo:

```
LLAMA_MODEL=Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M
```

Modelos menores (3B) rodam bem sem GPU. Modelos 7B+ ficam lentos só na CPU — recomendado ter GPU ou paciência.

Depois de mudar, recrie o container:
```bash
docker compose up -d --force-recreate llama-server
```

## Comandos úteis

| O que quer fazer | Comando |
|---|---|
| Parar tudo | `docker compose down` |
| Parar e apagar os dados (modelo, histórico) | `docker compose down -v` |
| Ver logs | `docker compose logs -f` |
| Atualizar as imagens | `docker compose pull && docker compose up -d` |

## Portas

- `3000` — Open WebUI (interface de chat)
- `8080` — API do llama-server (compatível com API da OpenAI, em `/v1`)
