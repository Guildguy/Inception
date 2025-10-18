all:
	docker-compose up --build -d

down:
	docker-compose down -v

re:
	docker-compose down -v
	docker-compose up --build -d

