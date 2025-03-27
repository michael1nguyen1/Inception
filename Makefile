.PHONY: up down clean fclean re

up:
	mkdir -p /home/$(shell whoami)/data/wordpress
	mkdir -p /home/$(shell whoami)/data/mariadb
	chmod -R 777 /home/$(shell whoami)/data/wordpress
	chmod -R 777 /home/$(shell whoami)/data/mariadb
	docker-compose -f srcs/docker-compose.yml up -d --build

down:
	docker-compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -a --force

fclean: clean
	rm -rf /home/$(shell whoami)/data/wordpress/*
	rm -rf /home/$(shell whoami)/data/mariadb/*
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean up

logs:
	docker-compose -f srcs/docker-compose.yml logs -f

help:
	@echo "=============================================================================="
	@echo "                    INCEPTION PROJECT HELPER COMMANDS                         "
	@echo "=============================================================================="
	@echo "DOCKER COMMANDS:"
	@echo "  docker ps                             - List running containers"
	@echo "  docker exec -it nginx /bin/sh         - Access NGINX container shell"
	@echo "  docker exec -it wordpress /bin/sh     - Access WordPress container shell"
	@echo "  docker exec -it mariadb /bin/sh       - Access MariaDB container shell"
	@echo "  docker logs nginx                     - View NGINX container logs"
	@echo "  docker logs wordpress                 - View WordPress container logs"
	@echo "  docker logs mariadb                   - View MariaDB container logs"
	@echo "  docker-compose -f srcs/docker-compose.yml ps   - Show container status"
	@echo ""
	@echo "MARIADB COMMANDS:"
	@echo "  docker exec -it mariadb mysql -u root -p       - Connect to MariaDB as root"
	@echo "  docker exec -it mariadb mysql -u wpuser -p     - Connect to MariaDB as wpuser"
	@echo ""
	@echo "  # Once connected to MariaDB, you can use:"
	@echo "  SHOW DATABASES;                       - List all databases"
	@echo "  USE wordpress;                        - Select WordPress database"
	@echo "  SHOW TABLES;                          - List all tables in current database"
	@echo "  SELECT * FROM wp_users;               - View WordPress users"
	@echo "  SELECT user_login,user_pass FROM wp_users;    - View usernames and password hashes"
	@echo ""
	@echo "WORDPRESS COMMANDS:"
	@echo "  docker exec -it wordpress wp user list --allow-root           - List WordPress users"
	@echo "  docker exec -it wordpress wp user update USER --user_pass=NEWPASS --allow-root - Change password"
	@echo "  docker exec -it wordpress wp plugin list --allow-root         - List installed plugins"
	@echo "  docker exec -it wordpress env | grep PASSWORD				 - View WordPress database password"
	@echo ""
	@echo "NGINX/SSL COMMANDS:"
	@echo "  curl -v --tlsv1.3 https://linhnguy.42.fr  - Test SSL connection"
	@echo "  docker exec -it nginx nginx -t        - Test NGINX configuration"
	@echo ""
	@echo "VOLUME/DATA VERIFICATION:"
	@echo "  ls -la /home/$(shell whoami)/data/wordpress        - Check WordPress volume content"
	@echo "  ls -la /home/$(shell whoami)/data/mariadb          - Check MariaDB volume content"
	@echo "  docker volume ls                      - List all Docker volumes"
	@echo ""
	@echo "NETWORK VERIFICATION:"
	@echo "  docker network ls                     - List all Docker networks"
	@echo "  docker network inspect inception_network - View network details and connected containers"
	@echo ""
	@echo "=============================================================================="