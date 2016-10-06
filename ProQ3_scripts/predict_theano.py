#!/usr/bin/env python

from __future__ import division
import numpy as np
from keras.models import model_from_json
import sys

input_file = sys.argv[1]
output_file = sys.argv[2]
model_json = sys.argv[3]
model_weights = sys.argv[4]

model = model_from_json(open(model_json).read())
model.load_weights(model_weights)
model.compile(loss='mse', optimizer='adadelta')

#data = np.loadtxt('stage1/T0999/server01_TS1.pdb.repacked.proq3.svm.txt.cut')[:, :336]
data = np.loadtxt(input_file)[:, 1:]
values = model.predict(data, verbose=1).flatten()

np.savetxt(output_file, values)
print

