**[Português](README.pt.md) | [English](README.en.md) | [Español](README.es.md)**

# ai-containers

Run a local AI model (LLM) with a ChatGPT-like chat interface, using only Docker. Nothing sent to the cloud, no API costs.

Works on **Linux, Windows, and Mac**. Runs on CPU by default (works on any machine); on Linux with an Intel or AMD GPU you can accelerate via Vulkan.

## Which model to run

| Your GPU | Model | Download |
|---|---|---|
| No GPU (CPU only) | Qwen2.5 3B | ~2.1 GB |
| 4-6 GB VRAM | Qwen2.5 3B | ~2.1 GB |
| 8 GB VRAM | Qwen2.5 7B | ~4.7 GB |
| 12 GB VRAM | Qwen2.5 14B | ~9 GB |
| 24 GB+ VRAM | Qwen2.5 32B | ~20 GB |

These numbers are just the model's download size — your GPU also needs extra VRAM headroom to hold the conversation (context). When in doubt, pick the model further up the table. `start.sh` (next section) asks about this and sets everything up correctly.

## Requirements

- **Docker** installed and running.
  - Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Linux: [Docker Engine](https://docs.docker.com/engine/install/)
- About 6GB of free disk space (model + images).

## How to run

1. Clone the repository:
   ```bash
   git clone <this-repository-url>
   cd ai-containers
   ```

2. If you're using an Intel or AMD GPU on Linux, install the Vulkan drivers first (Ubuntu/Debian):
   ```bash
   sudo apt install -y mesa-vulkan-drivers vulkan-tools libvulkan1
   ```

3. Run the setup script — it asks which model you want and whether you have a GPU, then brings everything up:
   ```bash
   ./start.sh
   ```
   (Windows: run it from Git Bash or WSL, which come bundled with Docker Desktop.)

4. Wait for the model download (first run only). Follow along with:
   ```bash
   docker compose logs -f llama-server
   ```
   Once you see `model loaded` and `listening on http://0.0.0.0:8080`, it's ready.

5. Open `http://localhost:3000` in your browser, create your local account (the first account created becomes admin), and start chatting. The model already shows up ready to select.

Done — no API key, no account with any service, everything runs on your machine.

> NVIDIA on Linux or GPU on Windows/WSL2 aren't set up here — it's possible, but it needs a different compose override (nvidia-container-toolkit). Out of scope for this repo for now.

<details>
<summary>Want to run it without the script, by hand?</summary>

Set `LLAMA_MODEL` in `.env` first (see [Changing the model](#changing-the-model)), then:

- Without GPU:
  ```bash
  docker compose up -d
  ```
- With GPU:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
  ```

</details>

## How to check if the GPU is being used

1. Confirm Vulkan can see your GPU:
   ```bash
   docker run --rm --device /dev/dri ghcr.io/ggml-org/llama.cpp:server-vulkan --list-devices
   ```
   You should see something like `Vulkan0: Intel(R) Arc(tm) B580 Graphics (BMG G21) (12216 MiB, 1824 MiB free)` — with your card's name. If nothing shows up, or only `llvmpipe` (software rendering) appears, the GPU isn't being detected.

2. Watch GPU usage live during a conversation:
   - Intel: `sudo apt install -y intel-gpu-tools` then `sudo intel_gpu_top`
   - AMD: `sudo apt install -y radeontop` then `sudo radeontop`

   Send a message in the chat and watch the usage spike.

3. No-install alternative: watch CPU usage with `top` during a conversation — if it stays mostly idle, inference is running on the GPU. It's indirect, but works as a quick signal.

## Changing the model

Easiest: run `./start.sh` again and pick a different model from the list.

By hand: create a `.env` file from `.env.example`:

```bash
cp .env.example .env
```

Then change the `LLAMA_MODEL` variable to any GGUF repository on Hugging Face, in `repository:quant` format, e.g.:

```
LLAMA_MODEL=Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M
```

Smaller models (3B) run fine without a GPU. 7B+ models get slow on CPU alone — a GPU (or patience) is recommended.

After changing it, recreate the container:
```bash
docker compose up -d --force-recreate llama-server
```

## Useful commands

| What you want to do | Command |
|---|---|
| Stop everything | `docker compose down` |
| Stop and delete the data (model, history) | `docker compose down -v` |
| View logs | `docker compose logs -f` |
| Update the images | `docker compose pull && docker compose up -d` |

## Ports

- `3000` — Open WebUI (chat interface)
- `8080` — llama-server API (OpenAI-compatible, at `/v1`)
