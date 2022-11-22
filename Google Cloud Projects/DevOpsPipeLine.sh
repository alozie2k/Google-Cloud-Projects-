#Task 1. Create a Git repository
#In the Cloud Console, on the Navigation menu, click Source Repositories. A new tab will open.
#Click Add repository.
#Select Create new repository and click Continue.
#Name the repository devops-repo.
#Select your current project ID from the list.
#Click Create.
#Return to the Cloud Console, and click Activate Cloud Shell (Cloud Shell icon).
#Then put this command  to create a folder called gcp-course:
mkdir gcp-course
#change to that folder
cd gcp-course
#then clone this repository with this command
gcloud source repos clone devops-repo
# previous command created an empty folder called devops-repo. Change to that folder:
cd devops-repo
#In Cloud Shell, click Open Editor (Editor icon) to open the code editor. If prompted click Open in a new window.
#Select the gcp-course > devops-repo folder in the explorer tree on the left.
#Click on devops-repo
#On the File menu, click New File
#Put the following code
from flask import Flask, render_template, request
app = Flask(__name__)
@app.route("/")
def main():
    model = {"title": "Hello DevOps Fans."}
    return render_template('index.html', model=model)
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080, debug=True, threaded=True)
    
#To save your changes. Press CTRL + S, and name the file as main.py.
#Click on SAVE
#Click on the devops-repo folder.
#Click on the File menu, click New Folder, Enter folder name as templates.
#Click OK
#Right-click on the templates folder and create a new file called layout.html.
#Add the following code and save the file as I did before:
<!doctype html>
<html lang="en">
<head>
    <title>{{model.title}}</title>
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css">
</head>
<body>
    <div class="container">
        {% block content %}{% endblock %}
        <footer></footer>
    </div>
</body>
</html>
#Also in the templates folder, add another new file called index.html.
#Add the following code and save the file as I did before:
{% extends "layout.html" %}
{% block content %}
<div class="jumbotron">
    <div class="container">
        <h1>{{model.title}}</h1>
    </div>
</div>
{% endblock %}
#In Python, application prerequisites are managed using pip. 
#Now will add a file that lists the requirements for this application.

#In the devops-repo folder (not the templates folder), 
#create a New File and add the following to that file and save it as requirements.txt:
Flask==2.0.3
#save the files to the repository. 
#First, you need to add all the files you created to your local Git repo. In Cloud Shell, enter the following code:
cd ~/gcp-course/devops-repo
git add --all
#Identitfy myself to commit changes to the repository
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
#commit the changes locally:
git commit -a -m "Initial Commit"
#now updating the Git repository I created in Cloud Source Repositories
git push origin master

#Task 3 define a docker build 
#The first step to using Docker is to create a file called Dockerfile. 
#This file defines how a Docker container is constructed
#In the Cloud Shell Code Editor, expand the gcp-course/devops-repo folder. With the devops-repo folder selected, on the File menu, click New File and name the new file Dockerfile.
#The file Dockerfile is used to define how the container is built.
#At the top of the file, enter the following:
FROM python:3.7
#This is the base image. You could choose many base images 
# using one with Python already installed on it.

#These lines copy the source code from the current folder into the /app folder in the container image.
WORKDIR /app
COPY . .

#This uses pip to install the requirements of the Python application into the container. 
#Gunicorn is a Python web server that will be used to run the web app.
RUN pip install gunicorn
RUN pip install -r requirements.txt

#The environment variable sets the port that the application will run on (in this case, 80). 
#The last line runs the web app using the gunicorn web server.
ENV PORT=80
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app

#Task 4. Manage Docker images with Cloud Build and Container Registry
#make sure im in the correct folder 
cd ~/gcp-course/devops-repo
#The Cloud Shell environment variable DEVSHELL_PROJECT_ID automatically has your current project ID stored. 
#The project ID is required to store images in Container Registry. 
#Enter the following command to view the project ID:
echo $DEVSHELL_PROJECT_ID
#Enter the following command to use Cloud Build to build your image:
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/devops-image:v0.1 .

#Return to the Cloud Console and on the Navigation menu ( Navigation menu icon), click Container Registry. 
#The image should be on the list.
#Now navigate to the Cloud Build service, and the build should be listed in the history.
#Will now try running this image from a Compute Engine virtual machine.
#Navigate to the Compute Engine service.
#Click Create Instance to create a VM.
#On the Create an instance page, specify the following, and leave the remaining settings as their defaults:
Property	Value
Container	Click DEPLOY CONTAINER
Container image	gcr.io/<your-project-id-here>/devops-image:v0.1 (change the project ID where indicated) and click SELECT
Firewall	Allow HTTP traffic
#Once the VM starts, created a browser tab and made a request to this new VM's external IP address

#Now will now save your changes to your Git repository. 
#In Cloud Shell, enter the following to make sure you are in the right folder and add your new Dockerfile to Git:
cd ~/gcp-course/devops-repo
git add --all
#Commit your changes locally
git commit -am "Added Docker Support"
#Push your changes to Cloud Source Repositories:
#git push origin master
#Return to Cloud Source Repositories and verify that your changes were added to source control.

#On the Navigation menu (Navigation menu icon), click Container Registry. At this point,  should have a folder named devops-image with at least one container in it.
#On the Navigation menu, click Cloud Build. The Build history page should open, and one or more builds should be in my history.
#Click the Triggers link on the left.
#Click Create trigger.
#Name the trigger devops-trigger.
#Select your devops-repo Git repository under repository dropdown.
#Select .*(any branch) for the branch.
#Choose Dockerfile for Configuration and select the default image.
#Accept the rest of the defaults, and click Create.
#To test the trigger, click Run and then Run trigger.
#Click the History link and should see a build running. Wait for the build to finish, and then click the link to it to see its details.
#Scroll down and look at the logs. The output of the build here is what  would have seen if I was  running it on my machine.
#Return to the Container Registry service. should see a new folder, devops-repo, with a new image in it.
#Return to the Cloud Shell Code Editor. Find the file main.py in the gcp-course/devops-repo folder.
#In the main() function, change the title property to "Hello Build Trigger." as shown below:
@app.route("/")
def main()
    model = {"title":  "Hello Build Trigger."}
    return render_template(`index.html`, model=model)
#Commit the change with the following command
cd ~/gcp-course/devops-repo
git commit -a -m "Testing Build Trigger"
#push your changes to Cloud Source Repositories:
git push origin master
#Return to the Cloud Console and the Cloud Build service. You should see another build running.

#When the build completes, click on it to see its details. Under Execution Details, copy the Image link
#Go to the Compute Engine service. As I did earlier, create a new virtual machine to test this image. 
#Click DEPLOY CONTAINER and paste the image you just copied.
#Select Allow HTTP traffic.
#When the machine is created, I test the change by making a request to the VM's external IP address in my browser. 
#and the new message is displayed.
