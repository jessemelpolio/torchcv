#!/usr/bin/env bash

# check the enviroment info
nvidia-smi
PYTHON="python"

export PYTHONPATH="/home/donny/Projects/TorchCV":${PYTHONPATH}

cd ../../../

DATA_DIR="/home/donny/DataSet/GAN/NIR2VIS"
TAG="dev"

MODEL_NAME="cyclegan"
CHECKPOINTS_NAME="it_cyclegan_nir2vis_gan"$2
CONFIG_FILE='configs/gan/face/it_cyclegan_nir2vis_gan.conf'
MAX_EPOCH=200

LOG_DIR="./log/gan/face/"
LOG_FILE="${LOG_DIR}${CHECKPOINTS_NAME}.log"

if [[ ! -d ${LOG_DIR} ]]; then
    echo ${LOG_DIR}" not exists!!!"
    mkdir -p ${LOG_DIR}
fi


if [[ "$1"x == "train"x ]]; then
  ${PYTHON} -u main.py --config_file ${CONFIG_FILE} --phase train --gpu 1 --model_name ${MODEL_NAME} --tag ${TAG} \
                       --data_dir ${DATA_DIR} --max_epoch ${MAX_EPOCH} \
                       --checkpoints_name ${CHECKPOINTS_NAME}  2>&1 | tee ${LOG_FILE}

elif [[ "$1"x == "resume"x ]]; then
  ${PYTHON} -u main.py --config_file ${CONFIG_FILE} --phase train --gpu 0 --model_name ${MODEL_NAME} --tag ${TAG} \
                       --data_dir ${DATA_DIR} --max_iters ${MAX_EPOCH} \
                       --resume_continue y --resume ./checkpoints/gan/face/${CHECKPOINTS_NAME}_latest.pth \
                       --checkpoints_name ${CHECKPOINTS_NAME}  2>&1 | tee -a ${LOG_FILE}

elif [[ "$1"x == "test"x ]]; then
  ${PYTHON} -u main.py --config_file ${CONFIG_FILE} --phase test --gpu 0 --tag ${TAG} \
                       --model_name ${MODEL_NAME} --checkpoints_name ${CHECKPOINTS_NAME} \
                       --resume ./checkpoints/gan/face/${CHECKPOINTS_NAME}_latest.pth \
                       --test_dir ${DATA_DIR}/protocols --root_dir ${DATA_DIR} --out_dir test  2>&1 | tee -a ${LOG_FILE}

else
  echo "$1"x" is invalid..."
fi
