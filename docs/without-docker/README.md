Método 1 — CLI con Ollama

Ollama es la forma más simple por terminal.

Instalar Ollama

curl -fsSL https://ollama.com/install.sh | sh

Descargar y correr Qwen2.5 14B

# Descarga + corre el modelo (Q4_K_M, ~8.9 GB)
ollama run qwen2.5:14b

# O solo descargarlo sin correrlo
ollama pull qwen2.5:14b

Comandos útiles

ollama list          # ver modelos descargados
ollama ps            # ver modelos corriendo
ollama stop qwen2.5:14b
ollama rm qwen2.5:14b   # borrar

Una vez que corra, Ollama expone un servidor en http://localhost:11434 compatible con la API de OpenAI.

---
Método 2 — GUI con LM Studio

1. Bajá LM Studio desde lmstudio.ai (tiene versión Linux, Mac y Windows)
2. Instalalo y abrilo
3. En la barra de búsqueda escribí qwen2.5-14b
4. Elegí una versión cuantizada — recomiendo Q4_K_M (balance calidad/peso)
5. Click en Download
6. Una vez descargado, andá a la pestaña Local Server (ícono <->)
7. Cargá el modelo y presioná Start Server

El servidor corre en http://localhost:1234/v1 (compatible con API de OpenAI).

---
Conectar con OpenCode

Dependiendo de qué uses:

Con Ollama

# En tu config de OpenCode, apuntá a:
OPENAI_API_BASE=http://localhost:11434/v1
OPENAI_API_KEY=ollama   # cualquier string, no valida
MODEL=qwen2.5:14b

Con LM Studio

OPENAI_API_BASE=http://localhost:1234/v1
OPENAI_API_KEY=lm-studio
MODEL=qwen2.5-14b   # el nombre que muestra LM Studio
