# Usar una imagen base que incluye CUDA 10.2
FROM andrewseidl/nvidia-cuda:10.2-base-ubuntu20.04

# Set the working directory
WORKDIR /app

# Update CUDA Keys
RUN rm /etc/apt/sources.list.d/cuda.list && \
    apt-key del 7fa2af80 && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub

# Instalar Python 3.8, herramientas básicas y herramientas de compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        python3.8 \
        python3-pip \
        python3.8-dev \
        build-essential \  
        libjpeg-dev \     
        libpng-dev && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 && \
    update-alternatives --set python3 /usr/bin/python3.8 && \
    ln -s /usr/bin/python3.8 /usr/local/bin/python3 && \
    ln -s /usr/bin/pip3 /usr/local/bin/pip && \
    rm -rf /var/lib/apt/lists/*

RUN python3.8 -m pip install --upgrade pip

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar el archivo requirements.txt al contenedor
COPY requirements.txt /app/requirements.txt

# Instalar dependencias, asegurándose de que pycocotools se compile correctamente
RUN python3.8 -m pip install torch==1.10.0+cu102 torchvision==0.11.0+cu102 torchaudio==0.10.0+cu102 -f https://download.pytorch.org/whl/torch_stable.html && \
    python3.8 -m pip install Cython && \ 
    python3.8 -m pip install -r requirements.txt && \
    python3.8 -m pip install setuptools==58.2.0 detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu102/torch1.10/index.html

# Copiar el resto de los archivos del proyecto al contenedor
COPY . /app
