# Deploy your own Serverless LLM on Google Cloud Run

## Preqs
Make sure the following APIs are all enabled in your GCP Project

```
gcloud services enable run.googleapis.com \
    cloudbuild.googleapis.com \
    storage.googleapis.com \
    artifactregistry.googleapis.com
```

If you want to use Zonal Redudancy, you will need to request a Quota increase for the following Quota. The sample code is configured to disable Zonal Redudancy.
Total Nvidia L4 GPU allocation with zonal redundancy, per project per region

Replace [your gcp project id here] with your GCP project id

## Create a repo on Artifact Registry to host our Docker images

```
gcloud artifacts repositories create ollama-sidecar-gemma-repo --repository-format=docker \
    --location=us-central1 --description="Serverless Ollama + OpenWebUI Gemma demo" \
    --project=[your gcp project id here]
```

## Use Cloud Build to create the Docker image for our Ollama + Gemma3 LLM container
```
gcloud builds submit \
   --tag us-central1-docker.pkg.dev/[your gcp project id here]/ollama-sidecar-gemma-repo/ollama-gemma-4b \
   --machine-type e2-highcpu-32
```

## Create the Open-webui Docker image

```
docker pull ghcr.io/open-webui/open-webui:main
```

### Make sure you pull the x86 image since Cloud Run only supports x86 images. If you are on a Apple Silcon Mac this is required:

```
docker pull --platform linux/amd64 ghcr.io/open-webui/open-webui:main
```

docker pull --platform linux/x86_64 ghcr.io/open-webui/open-webui:main

### Tag and push the image to the Artifact Registry repository

```
docker tag ghcr.io/open-webui/open-webui:main us-central1-docker.pkg.dev/[your gcp project id here]/ollama-sidecar-gemma-repo/openwebui
docker push us-central1-docker.pkg.dev/[your gcp project id here]/ollama-sidecar-gemma-repo/openwebui
```

## Deploy the Cloud Run Service
This is a single Run service with two containers: Open-webui and Ollama+Gemma3 LLM

```
gcloud run services replace service.yaml
```

https://cloud.google.com/run/docs/configuring/services/gpu#zonal-redundancy
https://cloud.google.com/run/docs/configuring/services/gpu#yaml

## Run the image locally
```
docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main
```