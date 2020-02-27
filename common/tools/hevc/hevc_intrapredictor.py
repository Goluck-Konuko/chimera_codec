from hevc_augmenter import Augmenter
import numpy as np

def intra_predictor(left_ref,top_ref,original_pu,puSize):
    #initialization
    minCost = 10000
    selectedMode = 10
    prediction = np.zeros((puSize,puSize))
    left_ref = np.array(left_ref)
    top_ref = np.array(top_ref)
    original_pu = np.array(original_pu)
    augmenter = Augmenter(left_ref,top_ref,original_pu,puSize)
    #R(D) optimization to select the best prediction
    for mode in range(35):
        pred = augmenter.prediction(mode)
        cost = augmenter.rd_cost()
        if cost<minCost:
            minCost = cost
            prediction = pred
            selectedMode = mode
    return prediction,selectedMode



# left = np.array([222, 4, 44, 5,222, 4, 44, 5])
# top = np.array([5, 33,122,6,2,222, 4, 44, 5])
# original = np.array([[53, 34,2,6,6,2,222, 4,],[51, 10,21,2, 43,34,2,69],[53, 34,2,6,6,2,222, 4,],[2,43,34,2,69, 94,13, 58],[2, 43,34,2,6,6,50, 5],[51, 10,21,2, 43,34,2,69],[53, 34,2,6,6,2,222, 4,],[2,43,34,2,69, 94,13, 58]])
# prediction,selectedMode = intra_predictor(left, top,original,8)
# print(prediction.shape)
# print(selectedMode)