
CREATE OR REPLACE TABLE ML.Algorithm (
	Id INT IDENTITY PRIMARY KEY,
	Name VARCHAR(256),
	"Type" VARCHAR(256),
	"Method" VARCHAR(256),
	"Output" VARCHAR(256),
	"Language" VARCHAR(256),
	"Module" VARCHAR(256),
	Submodule VARCHAR(1024),
	"Function" VARCHAR(256),
	IsEnsemble BOOL,
	IncrementalLearn BOOL,
	Priority INT
);

CREATE OR REPLACE TABLE ML.AlgorithmTmp (
	Name VARCHAR(256),
	"Type" VARCHAR(256),
	"Method" VARCHAR(256),
	"Output" VARCHAR(256),
	"Language" VARCHAR(256),
	"Module" VARCHAR(256),
	Submodule VARCHAR(1024),
	"Function" VARCHAR(256),
	IsEnsemble BOOL,
	IncrementalLearn BOOL,
	Priority INT
);

-- Types
-- - Random Forest

-- Methods
-- - Supervised
-- - Unsupervised
-- - Reinforcement
-- - Semi-Supervised

-- Outputs
-- - Classification
-- - Regression
-- - Dimensionality Reduction

-- Languages
-- - Python
-- - Python3
-- - R

-- Modules
-- - sklearn

INSERT INTO	ML.AlgorithmTmp
			(Name, "Type", "Method", "Output", "Language", "Module", Submodule, "Function", IsEnsemble, IncrementalLearn, Priority)
VALUES		('Random Forest Classifier', 'Random Forest', 'Supervised', 'Classification', 'Python3', 'sklearn', 'ensemble', 'RandomForestClassifier', true, false, 0),
			('Decision Tree Classifier', 'Decision Tree', 'Supervised', 'Classification', 'Python3', 'sklearn', 'tree', 'DecisionTreeClassifier', false, false, 0),
			('Linear Regression', 'Linear Regression', 'Supervised', 'Regression', 'Python3', 'sklearn', 'linear_model', 'LinearRegression', false, false, 0),
			('Decision Tree Regressor', 'Decision Tree', 'Supervised', 'Regression', 'Python3', 'sklearn', 'tree', 'DecisionTreeRegressor', false, false, 0),
			('Epsilon-Support Vector Regression', 'Support Vector', 'Supervised', 'Regression', 'Python3', 'sklearn', 'svm', 'SVR', false, false, 0);
		
INSERT INTO	ML.Algorithm
			(Name, "Type", "Method", "Output", "Language", "Module", Submodule, "Function", IsEnsemble, IncrementalLearn, Priority)
SELECT		Name, "Type", "Method", "Output", "Language", "Module", Submodule, "Function", IsEnsemble, IncrementalLearn, Priority
FROM		ML.AlgorithmTmp
MINUS
SELECT		Name, "Type", "Method", "Output", "Language", "Module", Submodule, "Function", IsEnsemble, IncrementalLearn, Priority
FROM		ML.Algorithm
ORDER BY	"Language", "Module", Submodule, "Function";

DROP TABLE ML.AlgorithmTmp;

SELECT	*
FROM	ML.Algorithm;
