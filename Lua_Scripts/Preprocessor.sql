CREATE OR REPLACE SCRIPT ML.Preprocessor() AS
--import('ML.Preprocessor_Predict', 'predict')
import('ML.Preprocessor_Train', 'train')

text = sqlparsing.getsqltext()
--text = predict.process(text)
text = train.process(text)
sqlparsing.setsqltext(text)

--------

ALTER	SESSION
SET		sql_preprocessor_script = ML.Preprocessor;

ALTER	SYSTEM
SET		sql_preprocessor_script = ML.Preprocessor;
