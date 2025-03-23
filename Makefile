
.PHONY: up down clean fclean re

up:
	mkdir -p /home/\$(shell whoami)/data/wordpress
	mkdir -p /home/\$(shell whoami)/data/mariadb
	chmod -R 777 /home/\$(shell whoami)/data/wordpress
	chmod -R 777 /home/\$(shell whoami)/data/mariadb
	docker-compose -f srcs/docker-compose.yml up -d --build

down:
	docker-compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -a --force

fclean: clean
	sudo rm -rf /home/\$(shell whoami)/data/wordpress/*
	sudo rm -rf /home/\$(shell whoami)/data/mariadb/*
	docker volume rm \$$(docker volume ls -q) 2>/dev/null || true

re: fclean up

logs:
	docker-compose -f srcs/docker-compose.yml logs -f