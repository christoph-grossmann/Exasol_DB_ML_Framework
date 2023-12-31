CREATE OR REPLACE TABLE ML.Model (
	Id INT IDENTITY PRIMARY KEY,
	Name NVARCHAR(256),
	AlgorithmId INT REFERENCES ML.Algorithm (Id),
	"Source" NVARCHAR(256),
	Features NVARCHAR(10000),
	FeatureCount INT,
	Labels NVARCHAR(10000),
	LabelCount INT,
	Settings NVARCHAR(10000),
	Parameters NVARCHAR(10000)
);

SELECT	*
FROM	ML.Model;
