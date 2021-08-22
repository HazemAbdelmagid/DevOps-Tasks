from flask import Flask 

app = Flask(__name__)

@app.route("/")
def index():
    return "Welcome everyone to My Main page!"

@app.route("/hi/")
def name():
    return "What is your name?"
	
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
