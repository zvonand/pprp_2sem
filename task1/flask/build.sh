pip-compile --output-file=requirements.txt --resolver=backtracking requirements.in

docker build -t zvonand/flask:1.0 .