sudo pkill python;
git clone https://github.com/krazuregame/development.git;
cd development/sample/ROSE/;
sudo apt install python-pip -y;
pip install --user pipenv;
source ~/.bashrc;
pip install --upgrade pip;
pipenv install;
pipenv shell;
./rose-server & ./rose-client ./examples/cosmos.py & ./rose-client examples/random-driver.py &
