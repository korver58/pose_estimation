FROM pytorch/pytorch:2.3.1-cuda11.8-cudnn8-devel

ARG UID=1000
ARG USER=developer
RUN useradd -m -u ${UID} ${USER}
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/${USER}
WORKDIR ${HOME}

RUN apt-get update && apt-get install -y \
    curl wget git build-essential cmake \
    python3-dev python3-pip python-is-python3 \
    # for opemcv
    qtbase5-dev libopencv-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# install mmpose
# https://mmpose.readthedocs.io/en/latest/installation.html
# https://github.com/open-mmlab/mmdetection/issues/6765
# https://developer.nvidia.com/cuda-gpus#compute
# RTX4080
ENV TORCH_CUDA_ARCH_LIST="8.9"
ENV PATH="${PATH}:/usr/local/cuda/bin"
ENV FORCE_CUDA="1"
ENV MMCV_WITH_OPS=1
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install -U openmim
# root権限でのmimパッケージのインストール
RUN mim install mmengine==0.10.4 mmdet==3.3.0 mmpose==1.3.1 mmcv==2.1.0

# RUN chmod -R 777 ${HOME}
RUN chown -R ${USER}:${USER} ${HOME}

USER ${USER}
COPY --chown=${USER} requirements.txt ./requirements.txt
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install -r requirements.txt

CMD ["/bin/bash"]
