
.PHONY: up down clean fclean re

up:
	sudo mkdir -p /home/linhnguy/data/wordpress
	sudo mkdir -p /home/linhnguy/data/mariadb
	sudo chown -R \$(shell whoami):\$(shell whoami) /home/linhnguy/data
	docker-compose -f srcs/docker-compose.yml up -d --build

down:
	docker-compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -a --force

fclean: clean
	sudo rm -rf /home/linhnguy/data/wordpress/*
	sudo rm -rf /home/linhnguy/data/mariadb/*
	docker volume rm \$$(docker volume ls -q) 2>/dev/null || true

re: fclean up

logs:
	docker-compose -f srcs/docker-compose.yml logs -f
