SOURCES = lambda_function.py

test:
	if [ -f ./venv/bin/activate ]; then . venv/bin/activate; fi \
	&& pip install -r requirements.txt \
	&& python3 -m unittest test.py
