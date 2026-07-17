**[Português](README.pt.md) | [English](README.en.md) | [Español](README.es.md)**

# ai-containers

Ejecuta un modelo de IA (LLM) local, con una interfaz de chat tipo ChatGPT, usando solo Docker. Sin enviar nada a la nube, sin costo de API.

Funciona en **Linux, Windows y Mac**. Por defecto corre en la CPU (funciona en cualquier máquina); en Linux con GPU Intel o AMD se puede acelerar vía Vulkan.

## Qué modelo ejecutar

| Tu GPU | Modelo | Descarga |
|---|---|---|
| Sin GPU (solo CPU) | Qwen2.5 3B | ~2,1 GB |
| 4-6 GB de VRAM | Qwen2.5 3B | ~2,1 GB |
| 8 GB de VRAM | Qwen2.5 7B | ~4,7 GB |
| 12 GB de VRAM | Qwen2.5 14B | ~9 GB |
| 24 GB+ de VRAM | Qwen2.5 32B | ~20 GB |

Estos valores son solo el tamaño de descarga del modelo — la GPU también necesita un margen extra de VRAM para mantener la conversación (contexto). Si tienes dudas, elige el modelo de más arriba en la tabla. El `start.sh` (siguiente sección) ya pregunta esto y configura todo correctamente.

## Requisitos

- **Docker** instalado y en ejecución.
  - Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - Linux: [Docker Engine](https://docs.docker.com/engine/install/)
- Unos 6GB libres en disco (modelo + imágenes).

## Cómo ejecutarlo

1. Clona el repositorio:
   ```bash
   git clone <url-de-este-repositorio>
   cd ai-containers
   ```

2. Si vas a usar una GPU Intel o AMD en Linux, instala primero los drivers Vulkan (Ubuntu/Debian):
   ```bash
   sudo apt install -y mesa-vulkan-drivers vulkan-tools libvulkan1
   ```

3. Ejecuta el script de configuración — te pregunta qué modelo quieres y si tienes GPU, y levanta todo:
   ```bash
   ./start.sh
   ```
   (Windows: ejecútalo desde Git Bash o WSL, que ya vienen junto con Docker Desktop.)

4. Espera la descarga del modelo (solo la primera vez). Síguela con:
   ```bash
   docker compose logs -f llama-server
   ```
   Cuando aparezca `model loaded` y `listening on http://0.0.0.0:8080`, ya está listo.

5. Abre `http://localhost:3000` en el navegador, crea tu cuenta local (la primera cuenta creada se vuelve admin) y empieza a conversar. El modelo ya aparece disponible para seleccionar.

Listo — sin clave de API, sin cuenta en ningún servicio, todo corre en tu máquina.

> NVIDIA en Linux o GPU en Windows/WSL2 no están configuradas aquí — se puede hacer, pero requiere un override de compose diferente (nvidia-container-toolkit). Fuera del alcance de este repositorio por ahora.

<details>
<summary>¿Quieres ejecutarlo sin el script, a mano?</summary>

Define `LLAMA_MODEL` en el `.env` primero (mira [Cambiar de modelo](#cambiar-de-modelo)), después:

- Sin GPU:
  ```bash
  docker compose up -d
  ```
- Con GPU:
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
  ```

</details>

## Cómo verificar si se está usando la GPU

1. Confirma que Vulkan detecta tu GPU:
   ```bash
   docker run --rm --device /dev/dri ghcr.io/ggml-org/llama.cpp:server-vulkan --list-devices
   ```
   Debería aparecer algo como `Vulkan0: Intel(R) Arc(tm) B580 Graphics (BMG G21) (12216 MiB, 1824 MiB free)` — con el nombre de tu tarjeta. Si no aparece nada, o solo aparece `llvmpipe` (renderizado por software), la GPU no está siendo detectada.

2. Observa el uso de la GPU en tiempo real durante una conversación:
   - Intel: `sudo apt install -y intel-gpu-tools` y después `sudo intel_gpu_top`
   - AMD: `sudo apt install -y radeontop` y después `sudo radeontop`

   Envía un mensaje en el chat y observa cómo sube el uso.

3. Alternativa sin instalar nada: monitorea la CPU con `top` durante una conversación — si se mantiene prácticamente ociosa, la inferencia está corriendo en la GPU. Es indirecto, pero sirve como indicio rápido.

## Cambiar de modelo

Más fácil: ejecuta `./start.sh` de nuevo y elige otro modelo de la lista.

A mano: crea un archivo `.env` a partir de `.env.example`:

```bash
cp .env.example .env
```

Y cambia la variable `LLAMA_MODEL` por cualquier repositorio GGUF de Hugging Face, en formato `repositorio:quant`, por ejemplo:

```
LLAMA_MODEL=Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M
```

Los modelos más pequeños (3B) funcionan bien sin GPU. Los modelos de 7B en adelante se vuelven lentos solo con CPU — se recomienda tener GPU o paciencia.

Después de cambiarlo, recrea el contenedor:
```bash
docker compose up -d --force-recreate llama-server
```

## Comandos útiles

| Qué quieres hacer | Comando |
|---|---|
| Detener todo | `docker compose down` |
| Detener y borrar los datos (modelo, historial) | `docker compose down -v` |
| Ver logs | `docker compose logs -f` |
| Actualizar las imágenes | `docker compose pull && docker compose up -d` |

## Puertos

- `3000` — Open WebUI (interfaz de chat)
- `8080` — API de llama-server (compatible con la API de OpenAI, en `/v1`)
