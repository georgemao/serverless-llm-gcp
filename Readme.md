# Deploy your own Serverless LLM on Google Cloud Run

gcloud artifacts repositories create ollama-sidecar-gemma-repo --repository-format=docker \
    --location=us-central1 --description="Serverless Ollama + OpenWebUI Gemma demo" \
    --project=gmao-test-project


gcloud builds submit \
   --tag us-central1-docker.pkg.dev/gmao-test-project/ollama-sidecar-gemma-repo/ollama-gemma-4b \
   --machine-type e2-highcpu-32



docker pull ghcr.io/open-webui/open-webui:main

docker pull --platform linux/x86_64 ghcr.io/open-webui/open-webui:main
docker pull --platform linux/amd64 ghcr.io/open-webui/open-webui:main

docker tag ghcr.io/open-webui/open-webui:main us-central1-docker.pkg.dev/gmao-test-project/ollama-sidecar-gemma-repo/openwebui
docker push us-central1-docker.pkg.dev/gmao-test-project/ollama-sidecar-gemma-repo/openwebui


gcloud  run services replace service.yaml

--no-gpu-zonal-redundancy



https://cloud.google.com/run/docs/configuring/services/gpu#zonal-redundancy
https://cloud.google.com/run/docs/configuring/services/gpu#yaml

Quota
Cloud Run Admin API
Total Nvidia L4 GPU allocation with zonal redundancy, per project per region


docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main