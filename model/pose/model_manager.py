#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Author: Donny You(youansheng@gmail.com)
# Select Pose Model for pose detection.


import torch

from model.pose.nets.open_pose_org import get_open_pose_org
from model.pose.nets.cpm import CPM
from model.pose.nets.open_pose import OpenPose
from model.pose.loss.pose_modules import OpenPoseLoss
from tools.util.logger import Logger as Log

MULTI_POSE_MODEL_DICT = {
    'openpose': OpenPose,
    'openpose_org': get_open_pose_org,
}

SINGLE_POSE_MODEL_DICT = {
    'cpm': CPM
}

POSE_LOSS_DICT = {
    'openpose_loss': OpenPoseLoss,
}

class ModelManager(object):
    def __init__(self, configer):
        self.configer = configer

    def get_multi_pose_model(self):
        model_name = self.configer.get('network', 'model_name')

        if model_name not in MULTI_POSE_MODEL_DICT:
            Log.error('Model: {} not valid!'.format(model_name))
            exit(1)

        model = MULTI_POSE_MODEL_DICT[model_name](self.configer)

        return model

    def get_single_pose_model(self):
        model_name = self.configer.get('network', 'model_name')

        if model_name not in SINGLE_POSE_MODEL_DICT:
            Log.error('Model: {} not valid!'.format(model_name))
            exit(1)

        model = SINGLE_POSE_MODEL_DICT[model_name](self.configer)

        return model

    def get_pose_loss(self, loss_type=None):
        key = self.configer.get('loss', 'loss_type') if loss_type is None else loss_type
        if key not in POSE_LOSS_DICT:
            Log.error('Loss: {} not valid!'.format(key))
            exit(1)

        loss = POSE_LOSS_DICT[key](self.configer)
        if self.configer.get('network', 'loss_balance') and len(range(torch.cuda.device_count())) > 1:
            from exts.tools.parallel.data_parallel import DataParallelCriterion
            loss = DataParallelCriterion(loss)

        return loss
