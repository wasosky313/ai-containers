#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "Qual modelo você quer rodar?"
echo

options=(
  "Qwen2.5 3B  - leve e rápido, roda bem sem GPU"
  "Qwen2.5 7B  - equilibrado, recomendado"
  "Qwen2.5 14B - mais capaz, recomendado ter GPU"
  "Qwen2.5 32B - o mais capaz, precisa de GPU com bastante VRAM (~20GB+)"
  "Outro (digitar manualmente repositorio:quant do Hugging Face)"
)

select opt in "${options[@]}"; do
  case $REPLY in
    1) MODEL="Qwen/Qwen2.5-3B-Instruct-GGUF:Q4_K_M"; break ;;
    2) MODEL="Qwen/Qwen2.5-7B-Instruct-GGUF:Q4_K_M"; break ;;
    3) MODEL="Qwen/Qwen2.5-14B-Instruct-GGUF:Q4_K_M"; break ;;
    4) MODEL="Qwen/Qwen2.5-32B-Instruct-GGUF:Q4_K_M"; break ;;
    5) read -rp "Repositório (ex: Qwen/Qwen2.5-7B-Instruct-GGUF:Q4_K_M): " MODEL; break ;;
    *) echo "Opção inválida, tenta de novo." ;;
  esac
done

echo "LLAMA_MODEL=$MODEL" > .env
echo
echo "Modelo escolhido: $MODEL"
echo

read -rp "Tem GPU Intel ou AMD no Linux e quer acelerar? [s/N] " GPU_ANSWER

echo
if [[ "$GPU_ANSWER" =~ ^[sS]$ ]]; then
  echo "Subindo os containers com aceleração de GPU..."
  docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
else
  echo "Subindo os containers (CPU)..."
  docker compose up -d
fi

echo
echo "Pronto! Acompanhe o download do modelo com:"
echo "  docker compose logs -f llama-server"
echo
echo "Quando aparecer 'model loaded' no log, abra http://localhost:3000 no navegador."
