# Use a imagem base do Anaconda
FROM continuumio/anaconda3

# Argumentos do container
ENV UNAME=lmuffato
ENV USER_ID=1000
ENV GROUP_ID=1000
ENV SPYDER_WORKING_DIR=/../../app/notebooks
ENV XDG_RUNTIME_DIR=/../../app/notebooks

ARG ROOT=/
ARG UNAME=lmuffato
ARG UID=1000
ARG GID=1000

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Add unprivileged user to run the image
RUN addgroup --gid ${GID} ${UNAME}
RUN adduser --uid ${UID} --ingroup ${UNAME} --shell /bin/sh --disabled-login ${UNAME}
RUN adduser ${UNAME} sudo
RUN echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER root

# Instala as dependêndias do anaconda
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y \
    python3-pyqt5 \
    python3-pyqt5.qtsvg \
    python3-qtconsole \
    python3-setuptools \
    python3-pip \
    net-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    zlib1g-dev \
    liblzma-dev \
    tk-dev \
    uuid-dev \
    build-essential \
    libpq-dev \
    gcc \
    libstdc++6 \
    libstdc++-12-dev \
    libglib2.0-0 \
    libx11-6 \
    libgl1-mesa-dri \
    libglx-mesa0 \
    mesa-utils \
    libpci3 \
    libglvnd0 \
    libegl1 \
    libxcb-glx0 \
    libxcb-dri3-0 \
    net-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y \
    libxcb-xinerama0 \
    libx11-xcb1 \
    libxcb1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-shm0 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-xkb1 \
    libxrender1 \
    libxkbcommon-x11-0 \
    libxext6 \
    libxft2 \
    libsm6 \
    libice6 \
    libgl1-mesa-glx \
    libglu1-mesa \
    libfontconfig1 \
    libfreetype6 \
    libdbus-1-3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Criar link simbólico para libstdc++ (spider)
RUN ln -sf /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /opt/conda/lib/libstdc++.so.6

COPY requirements.txt .

# Instale as dependências do Python
RUN pip install --no-cache-dir -r requirements.txt

RUN conda install pyqt=5 qt=5

# RUN conda update --all

RUN conda install spyder -y

# Ajustar permissões do diretório do projeto
RUN chown -R ${UID}:${GID} /app

# WORKDIR /app/notebooks

USER ${UNAME}

CMD ["tail", "-f", "/dev/null"]
