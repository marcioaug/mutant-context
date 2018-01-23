from sklearn import metrics


def measure_performance(X, y, clf):
    y_predicted = clf.predict(X)
    print('Accuracy: %f \n' % metrics.accuracy_score(y, y_predicted))
    print(metrics.classification_report(y, y_predicted), '\n')