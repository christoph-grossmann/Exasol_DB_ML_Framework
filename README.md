# Exasol-Database Machine-Learning Framework

A framework for extending SQL for machine learning on Exasol database systems.
This framework is not associated with the Exasol company.

> [!WARNING]  
> This page is still under construction.

## Introduction

```sql
CREATE MODEL "model" ON employees PREDICT (salary) USING ("position", birthyear);
```

```sql
SELECT name, "position", birthyear, PREDICT "model" USING ("position", birthyear)
FROM employees WHERE salary IS NULL;
```

## [Syntax for Training a Model](Documentation/SQL_Syntax_ML_Model_Creation.md)

[![SQL Syntax for Machine-Learning Model Creation][documentation/SQL_Syntax_ML_Model_Creation.png]](Documentation/SQL_Syntax_ML_Model_Creation.md)

## [Syntax for Predicting using a Model](Documentation/SQL_Syntax_ML_Model_Prediction.md)

[![SQL Syntax for Machine-Learning Model Prediction][Documentation/SQL_Syntax_ML_Model_Prediction.png]](Documentation/SQL_Syntax_ML_Model_Prediction.md)

## [Layers and Elements](Documentation/Layers_Elements_ML_Framework.md)

[![Layers and Elements of the Machine-Learning Framework][Documentation/Layers_Elements_ML_Framework.png]](Documentation/Layers_Elements_ML_Framework.md)

## Currently supported Algorithms

| Library      | Namespace    | Algorithm              | Output Type    |
| ------------ | ------------ | ---------------------- | -------------- |
| Scikit-Learn | ensemble     | RandomForestClassifier | Classification |
| Scikit-Learn | linear.model | LinearRegression       | Regression     |
| Scikit-Learn | svm          | SVR                    | Regression     |
| Scikit-Learn | tree         | DecisionTreeClassifier | Classification |
| Scikit-Learn | tree         | DecisionTreeRegressor  | Regression     | 

## Related Publications

- C. Großmann, J. Schildgen: _Integrating Machine Learning into SQL with Exasol_. LWDA 2023
- C. Großmann: _Extending SQL for Machine Learning_, Master thesis, Ostbayerische Tech-
nische Hochschule Regensburg, 2023. https://doi.org/10.35096/othr/pub-6059.
