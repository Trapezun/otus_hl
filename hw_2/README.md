# Домашнее задание 4
 - Для  запуска **Terraform**  необходимо в файле **variables.auto.tfvars** прописать свои данные.
 - В файл **id_rsa.pub** прописать свой публичный ключ. 
 - Для начала надо настроить сеть и запустить **Бастион**
	  - Перейти в каталог **Terraform/bastion**
		 - Запустить **Terraform init**
		 - Запустить **Terraform apply -var-file="./../variables.auto.tfvars"**
		 		 
**Все сервера создаются с фиксированными ИП адресами**

После создания бастиона надо создавать другие сервера. 	
	 - Перейти в каталог **Terraform/servers**
      - Запустить **Terraform init**
      - Запустить **Terraform apply -var-file="./../variables.auto.tfvars"**
      
Для БД будет поднято 3 сервера для самой БД, 2 сервера для **HAProxy**. Кроме того в **Yandex Cloud** будет поднят отдельный внутренний **Load Balancer** для этих **HAProxy**. Тк виртуальный ИП адрес в облаке НЕ работает.  

После создания серверов надо отдельно запускать **ansible** проекты. 

Для бастиона -  в каталоге **Ansible** запустить **start_bastion.yml**

Для создания БД кластера - в каталоге **AnsiblePostgresql** запустить  **ansible-playbook deploy_pgcluster.yml -i inventory**

Для создания Бизнес-логикии -  в каталоге **Ansible**  запустить **start_business.yml**

	








