# Base image with system dependencies
FROM nvidia/cuda:12.0.1-base-ubuntu22.04 

# Set environment variables to avoid tzdata prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    git curl build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev \
    libffi-dev liblzma-dev python3-pip python3-venv tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user matching the host UID and GID
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID usergroup && \
    useradd -m -u $USER_ID -g usergroup user && \
    mkdir -p /home/user && \
    chown -R user:usergroup /home/user

# Switch to the non-root user
USER user
ENV HOME=/home/user
ENV PATH=/home/user/.local/bin:$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH

# Install pyenv for Python management
RUN curl https://pyenv.run | bash && \
    eval "$(pyenv init --path)" && \
    pyenv install 3.12.0 && \
    pyenv global 3.12.0

# Clone the ComfyUI repository
WORKDIR /app
RUN git clone https://github.com/comfyanonymous/ComfyUI.git . && \
    chown -R user:usergroup /app

# Create a Python virtual environment and install dependencies
RUN python3 -m venv venv && \
    /app/venv/bin/pip install --upgrade pip && \
    /app/venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    /app/venv/bin/pip install -r requirements.txt

# Clone ComfyUI Manager into custom_nodes
RUN mkdir -p /app/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git /app/custom_nodes/ComfyUI-Manager

# Expose ComfyUI internal port
EXPOSE 8188

# Command to start ComfyUI
CMD ["/app/venv/bin/python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
