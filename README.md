# ComfyUI Docker - Windows and WSL2

This project provides a Dockerized setup for running ComfyUI with GPU acceleration, utilizing NVIDIA drivers, and integrating Traefik for routing. The output directory is mapped to a local Windows folder for easy access.

## File Overview

- `docker-compose.yml`: _Default_. Configures the `comfyui` service and integrates it with Traefik.
- `docker-compose.traefik.yml`: Configures the `comfyui` service with Traefik included.
- `Dockerfile`: Builds the Docker image with necessary dependencies for GPU support and ComfyUI.

## Prerequisites

### 1. Install Required Software

- WSL2 Distro of Ubuntu or similar
- Docker Desktop with WSL2 integration.
- NVIDIA drivers and NVIDIA Container Toolkit.

### 2. Existing Traefik Service

Ensure you have an existing Traefik service running on the `dev` network. You can also use the compose file with Traefik included. See `Setup Instructions` section below

Example Traefik `docker-compose.yml`:

```yaml
services:
  traefik:
    image: traefik:v2.9
    command:
      - "--log.level=DEBUG"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - dev
networks:
  dev:
    name: dev
```

Start Traefik:

```bash
docker-compose up -d
```

### 3. Ensure Required Volumes and Directories Exist

#### Shared Models Volume

The `models` volume must exist. Create from Docker Desktop or inside Ubuntu WSL:

```bash
docker volume create models
```

#### Host Output Directory

The host directory for output files must exist. The default create a local `./output` directory. For Windows, you can create the directory inside the Picture folder. Or from the command shell:

```cmd
mkdir "C:\Users\<YourUsername>\Pictures\Comfy"
```

Alter the docker-compose file and Replace `<YourUsername>` with your Windows username. See below.

## Setup Instructions

1. Clone this repository:

   ```bash
   git clone https://github.com/shaneturner/comfyui-docker.git
   cd comfyui-docker
   ```

   or to clone into current directory

   ```bash
   git clone https://github.com/shaneturner/comfyui-docker.git .
   ```

2. _Optional_ - Change from local Ubuntu output to windows folder output

   ```diff
   ...
   volumes:
     - models:/app/models
   - - "./output:/app/output"
   + - "/mnt/c/Users/<YourUsername>/Pictures/Comfy:/app/output"
   ...
   ```

   _Remember to change `<YourUsername>` to your actual username_

3. Build and start the container:

   ```bash
   docker-compose up --build
   ```

   Or build with Traefik included ( cannot run two instances ) and start the container:

   ```bash
   docker compose -f docker-compose.traefik.yml up -d
   ```

4. Access the application:
   Open `http://comfyui.localhost` in your browser.

## Key Points to Be Aware Of

### NVIDIA Drivers and GPU Acceleration

- Ensure NVIDIA drivers are installed and functional on the host system.
- Verify GPU access with:
  ```bash
  nvidia-smi
  ```

### Traefik Integration

- The `comfyui.localhost` hostname is routed via Traefik.
- Ensure Traefik is running and connected to the `dev` network.

### Host Directories

- The output directory in the container (`/app/output`) is bound to `output` in the local direcory unless you changed to the alternate windows folder in the docker-compose file in wich case it will be: `C:\Users\<YourUsername>\Pictures\Comfy`.
- Ensure the directory exists on the host.

### Networking

- The `comfyui` service runs on port `8188` internally and is exposed through Traefik.
- The `dev` network must exist and be shared between services:
  ```bash
  docker network create dev
  ```

## Troubleshooting

### Bad Gateway Error

If you encounter a "Bad Gateway" error:

1. Ensure Traefik is running.
2. Verify the `dev` network connection:
   ```bash
   docker network inspect dev
   ```
   Add services to the network if missing:
   ```bash
   docker network connect dev <service-name>
   ```

### Cannot Access Output Files

Ensure the host directory is accessible to Docker Desktop and has the correct permissions.

## License

This project is licensed under the MIT License.
