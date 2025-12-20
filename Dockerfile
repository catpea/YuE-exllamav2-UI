ARG CUDA_VERSION="12.4.1"
ARG CUDNN_VERSION=""
ARG UBUNTU_VERSION="22.04"
ARG DOCKER_FROM=nvidia/cuda:$CUDA_VERSION-cudnn$CUDNN_VERSION-devel-ubuntu$UBUNTU_VERSION
ARG GRADIO_PORT=7860

FROM $DOCKER_FROM AS base

WORKDIR /

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHON_VERSION=3.12
ENV CONDA_DIR=/opt/conda
ENV PATH="$CONDA_DIR/bin:$PATH"
# ENV NUM_GPUS=1
ENV DOWNLOAD_MODELS="YuE-s1-7B-anneal-en-cot-exl2-4.0bpw,YuE-s2-1B-general-exl2-6.0bpw,YuE-upsampler"

# Install dependencies required for Miniconda
RUN apt-get update -y && \
    apt-get install -y wget bzip2 ca-certificates git curl && \
    apt-get install nodejs -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ninja-build \
    ca-certificates \
    cmake \
    curl \
    emacs \
    git \
    jq \
    libcurl4-openssl-dev \
    libglib2.0-0 \
    libgl1-mesa-glx \
    libsm6 \
    libssl-dev \
    libxext6 \
    libxrender-dev \
    software-properties-common \
    openssh-server \
    openssh-client \
    git-lfs \
    vim \
    zip \
    unzip \
    zlib1g-dev \
    libc6-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV PATH="/opt/conda/envs/pyenv/bin:$PATH"


# Download and install Miniforge (conda-forge only, no TOS required)
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O miniforge.sh && \
    bash miniforge.sh -b -p $CONDA_DIR && \
    rm miniforge.sh && \
    $CONDA_DIR/bin/conda init bash && \
    $CONDA_DIR/bin/conda create -n pyenv python=3.12 -y && \
    $CONDA_DIR/bin/conda install -n pyenv openmpi mpi4py -y

# Define PyTorch versions via arguments
ARG PYTORCH="2.5.1"
ARG CUDA="124"

# Install PyTorch nightly for RTX 5080 (sm_120 Blackwell support)
# The stable 2.5.1 doesn't support sm_120, need nightly or 2.6+
RUN $CONDA_DIR/bin/conda run -n pyenv \
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu$CUDA

RUN $CONDA_DIR/bin/conda install -n pyenv nvidia/label/cuda-12.4.1::cuda-nvcc

RUN $CONDA_DIR/bin/conda run -n pyenv pip install setuptools

# Build and install exllamav2 from source with RTX 5080 support
# Set TORCH_CUDA_ARCH_LIST to include sm_120 (Blackwell)
ENV TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0;12.0"
RUN git clone https://github.com/turboderp/exllamav2 /tmp/exllamav2 && \
    cd /tmp/exllamav2 && \
    $CONDA_DIR/bin/conda run -n pyenv pip install -r requirements.txt && \
    $CONDA_DIR/bin/conda run -n pyenv pip install . && \
    cd / && rm -rf /tmp/exllamav2

# Install git lfs
RUN apt-get update && apt-get install -y git-lfs && git lfs install

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx

COPY docker/default /etc/nginx/sites-available/default

# Add Jupyter Notebook
RUN pip install jupyterlab ipywidgets jupyter-archive jupyter_contrib_nbextensions

RUN pip install -U "huggingface_hub[cli]"

EXPOSE 8888

# Tensorboard
# EXPOSE 6006 

# Debug
# RUN $CONDA_DIR/bin/conda run -n pyenv \
#     pip install debugpy

# EXPOSE 5678


# Copy the entire project
COPY --chmod=755 . /YuE-exllamav2-UI

COPY --chmod=755 docker/initialize.sh /initialize.sh
COPY --chmod=755 docker/entrypoint.sh /entrypoint.sh

# Expose the Gradio port
EXPOSE $GRADIO_PORT

CMD [ "/initialize.sh" ]
