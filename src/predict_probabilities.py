'''
predict_probabilities
fits algorithm to entire dataset
then predicts the class label of each instance in dataset
saves predictions to .txt file
@params
--------
model: algorithm to train and predict probabilities
X: attributes
y: class labels
'''


def predict_probabilities(model, X, y, iteration):
    model.fit(X, y)
    predictions = model.predict_proba(X)[:, 1]

    for prediction in predictions:
        with open('BRF_predict_proba_' + str(iteration) + '.txt', 'a') as f:
            f.write('\n' + str(prediction))
