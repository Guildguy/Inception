COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean:
	$(COMPOSE) down -v --rmi all

re: fclean all

#docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null

# https://fleite-j.42.fr/wp-admin

# entra no container mariadb
# sudo docker exec -it mariadb sh

# conecta e loga no mariadb
# mysql -u root -p

