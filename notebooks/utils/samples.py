def get_samples(df, label, frac=0.1, replace=True):
    X = get_x(df)
    X['y'] = get_y(df, label)

    X_train = X.sample(frac=frac, replace=replace)

    y = X['y']
    y_train = X_train['y']

    X = X.drop(['y'], axis=1)
    X_train = X_train.drop(['y'], axis=1)

    return X, y, X_train, y_train
