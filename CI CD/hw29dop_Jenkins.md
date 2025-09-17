Установить Jenkins на ВМ
Ознакомиться с дополнительным материалом (ссылка)
Написать простой пайплайн todoapp-php ci/cd, состоящий из этапов:
initialize - этап выводит приветственное сообщение "Start testing ToDo app; Build ${BUILD_NUMBER}"
checkout - этап клонирует репозиторий https://github.com/AnastasiyaGapochkina01/simplest-todo
test - этап проводит тестирование кода; 
	команда phpunit --log-junit test-results.xml (!! ВАЖНО: тесты могут падать)
finish - этап выводит завершающее сообщение "Tests finished"

Добавить к пайплайну todoapp-php ci/cd этап build image; 
этап должен запускаться только если при запуске 
был отмечен checkbox 'Build image'; 

image tag должен передаваться в виде строки при запуске билда, 
значение по умолчанию - latest

Добавить к пайплайну todoapp-php ci/cd checkbox 
'push image to docker hub' и этап, который будет 
пушить собранный docker image в ваш репозиторий на dockerhub,
 если checkbox отмечен

Добавить к пайплайну todoapp-php ci/cd этап 'Clean', который будет
удалять папку с проектом
удалять все неиспользуемые docker images

Добавить к пайплайну todoapp-php ci/cd этап 'deploy', 
который будет деплоить собранный image на удаленный хост

/var/lib/jenkins/workspace/hw29/simplest-todo$

для docker build image нужно на машине
```
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Проверка к удалённому серверу

```sudo su - jenkins
jenkins@jenkins:~$ ssh 10.129.0.19
docker ps -a
```
Почистим остатки с других задач
```
docker ps -qa | xargs docker rm -f
docker images -q | xargs docker rmi -f
docker system prune -fa 

exit
```
Сделал fork себе https://github.com/TapAleksej/simplest-todo/tree/main
Добавил Jenkins_build и  Jenkinsfile-deploy

Cоздал view hw48 на jenkins. 
В нём 2 pipeline:
	- simplest-build  - создаёт и пушит image на docker hub
	- hw29-deploy 	- скачивает image на удалённом хосте из docker hub и запускает докер контейнер с приложением


### Jenkins_build
```js
pipeline {	
	agent any	
	environment {
		PRJ_NAME="simplest-todo"
		FULL_IMG_NAME="alrexcom/${env.PRJ_NAME}"
		IMG_NAME="${env.PRJ_NAME}"
		WORKSPACEPATH="${WORKSPACE}/${env.PRJ_NAME}"
		GIT_URL="git@github.com:TapAleksej/simplest-todo.git"

	}
	parameters {
		booleanParam(name: 'RUN_TEST', defaultValue: true, description: 'Run test?' )
		booleanParam(name: 'BUILD_IMAGE', defaultValue: true, description: 'Build image?' )
		string(name: 'IMAGE_TAG', defaultValue: 'latest')	
		booleanParam(name: 'PUSH_IMG', defaultValue: true, description: 'push image to docker hub?' )		
	}
	stages {
	
		stage('initialize') {
			steps {
				echo "Start testing ToDo app; Build #${BUILD_NUMBER}"
			}
		}
		stage('checkout') {
			steps {
				script {					

                    sh """
                        if [ -d "${WORKSPACEPATH}/.git" ]; then
                            echo "Repository exists. Updating ..."
                            cd "${WORKSPACEPATH}"
                            git pull
                        else
                            echo "Cloning repository ..."
                            git clone ${GIT_URL} "${WORKSPACEPATH}"
                        fi 
					"""
				}	
			}		
		}			
		stage('test') {
			when {
				expression { params.RUN_TEST == true}
			}
			steps {
				script {
					sh """
						phpunit --log-junit test-results.xml
					"""
				}			
			}			
		}
		stage('finish') {
			steps {
				echo "Tests finished"			
			}
		}	
		stage('build image') {
			when {
				expression { params.BUILD_IMAGE == true}
			}
			steps {
				script {
					sh """						
						cd "${WORKSPACEPATH}"						
						docker build -t "${IMG_NAME}":${params.IMAGE_TAG} .	 --no-cache						
					"""
				}
			
			}			
		}	
		stage('push image to docker hub') {
			when {
				expression { params.PUSH_IMG == true}
			}
			steps {
				script {
					def push = { ->						
						withCredentials([usernamePassword(credentialsId: 'docker-token', usernameVariable: 'username', passwordVariable: 'password')]) {
								sh  """																			
									docker login -u ${username} -p ${password}
									docker tag "${IMG_NAME}":${params.IMAGE_TAG} "${FULL_IMG_NAME}":${params.IMAGE_TAG}						
									docker push "${FULL_IMG_NAME}":${params.IMAGE_TAG}										
								"""								
						}		
					}				
				
                    push()	
				}				
			}
		}		
		stage('Clean') {
				steps {
					script {
						sh """
							cd "${WORKSPACEPATH}"							
							docker images -qa | xargs docker rmi -f
							rm -rf "${WORKSPACEPATH}"							
						"""
					}
				}				
		}
		
		stage('Call Deploy Job') {	
		  steps {
			script {
			  build quietPeriod: 5, wait: false, job: 'hw29-deploy', parameters: [string(name: 'FULL_IMG_NAME', value: "${FULL_IMG_NAME}:${params.IMAGE_TAG}")]			  
			}
		  }
		}		
	}		
}						
```

#### Jenkinsfile-deploy
```js
def remote = [:]

pipeline {	
	agent any	
	environment {	
		GIT_URL="git@github.com:TapAleksej/simplest-todo.git"
		SERVER_HOST = "10.129.0.19"
		SERVER_NAME = "deb12"
	}
	parameters {
		string(name: 'FULL_IMG_NAME', description: 'Image to deploy')	
	}
	stages {
			
		stage('Prepare Credentials'){
		  steps {
			withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-key', keyFileVariable: 'private_key', usernameVariable: 'username')]) {
			  script {
				remote.name = "${env.SERVER_NAME}"
				remote.host = "${env.SERVER_HOST}"
				remote.user = "${username}"
				remote.identity = readFile "${private_key}"
				remote.allowAnyHosts = true
			  }
			}
		  }
		}			
		
		stage('deploy') {
			steps {
				script {
					def deploy = { ->						
						withCredentials([usernamePassword(credentialsId: 'docker-token', usernameVariable: 'username', passwordVariable: 'password')]) {
								sshCommand remote: remote, command:  """																			
									set -x;
									docker ps | grep "${FULL_IMG_NAME}" | xargs docker rm -f 
									echo "Container ${FULL_IMG_NAME} if exists deleted"
									docker login -u ${username} -p ${password}
									docker pull "${FULL_IMG_NAME}"
									//cd "${env.PRJ_DIR}"
									docker run -it -d --name test-"${BUILD_NUMBER}" "${FULL_IMG_NAME}"									
								"""								
						}	
					}	
					deploy()	
				}
			}
		}	
		
	}		
}						
```
На 10.129.0.19 запустил docker ps
<img width="1134" height="99" alt="image" src="https://github.com/user-attachments/assets/bc963b9d-a0b0-4de9-b156-6e04f84d4b5f" />
Докер контейнер развернут.
