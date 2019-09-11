---
title: 机器学习(x) DecisionTreeClassifier example
date: 2019-09-11 19:23:31
tags:
- decision tree
categories: ML
---

**数据集**为`sklearn.datasets.make_moons`.  

**训练模型**为`DecisionTreeClassifier`决策树.  

<!--more-->

``` python
import numpy as np
from sklearn.datasets import make_moons
from sklearn.model_selection import train_test_split
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import accuracy_score
from sklearn.tree import DecisionTreeClassifier

X, y = make_moons(n_samples=10000, noise=0.4, random_state=42)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

dt_clf = DecisionTreeClassifier(random_state=42)

params = {
    'max_depth': [5, 10, 14, 15],
    'max_leaf_nodes': [10, 50, 100]
}

grid_clf = GridSearchCV(dt_clf, param_grid=params, cv=5, verbose=2, n_jobs=4)
grid_clf.fit(X_train, y_train)

# Fitting 5 folds for each of 12 candidates, totalling 60 fits
# [Parallel(n_jobs=4)]: Using backend LokyBackend with 4 concurrent workers.
# [Parallel(n_jobs=4)]: Done  60 out of  60 | elapsed:    0.2s finished
# GridSearchCV(cv=5, error_score='raise-deprecating',
#              estimator=DecisionTreeClassifier(class_weight=None,
#                                               criterion='gini', max_depth=None,
#                                               max_features=None,
#                                               max_leaf_nodes=None,
#                                               min_impurity_decrease=0.0,
#                                               min_impurity_split=None,
#                                               min_samples_leaf=1,
#                                               min_samples_split=2,
#                                               min_weight_fraction_leaf=0.0,
#                                               presort=False, random_state=42,
#                                               splitter='best'),
#              iid='warn', n_jobs=4,
#              param_grid={'max_depth': [5, 10, 14, 15],
#                          'max_leaf_nodes': [10, 50, 100]},
#              pre_dispatch='2*n_jobs', refit=True, return_train_score=False,
#              scoring=None, verbose=2)

grid_clf.best_params_
# {'max_depth': 14, 'max_leaf_nodes': 50}
grid_clf.best_score_
# 0.8535
y_pred = grid_clf.best_estimator_.predict(X_train)
accuracy_score(y_train, y_pred)
# 0.87575
y_pred_test = grid_clf.best_estimator_.predict(X_test)
accuracy_score(y_test, y_pred_test)
# 0.8615
```
