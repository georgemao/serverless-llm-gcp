FROM ollama/ollama

# Listen on all interfaces, port 11434
ENV OLLAMA_HOST 0.0.0.0:11434

# Store model weight files in /models
ENV OLLAMA_MODELS /models

# Reduce logging verbosity
ENV OLLAMA_DEBUG false

# Never unload model weights from the GPU
ENV OLLAMA_KEEP_ALIVE -1 

# Store the model weights in the container image
ENV MODEL gemma3:4b
RUN ollama serve & sleep 5 && ollama pull $MODEL 

# Start Ollama
ENTRYPOINT ["ollama", "serve"]