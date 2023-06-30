

docker run --name mysql -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=mypassword -e MYSQL_DATABASE=mydb mysql:8 --character-set-server=utf8 --collation-server=utf8_general_ci

# docker exec -it mysql bash
# mysql -u root -p mydb
# ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'mypassword';
# exit

DROP TABLE IF EXISTS `jfrog_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jfrog_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cluster_name` varchar(255) NOT NULL DEFAULT '' COMMENT '',
  `log_time` varchar(255) NOT NULL DEFAULT '' COMMENT 'e.g. 2023-06-17 23:00:00',
  `log_ip` varchar(255) NOT NULL DEFAULT '' COMMENT '',  
  `put_count` BIGINT(11) NOT NULL DEFAULT '0' COMMENT '',
  `put_size` BIGINT(11) NOT NULL DEFAULT '0' COMMENT '',
  `get_count` BIGINT(11) NOT NULL DEFAULT '0' COMMENT '',
  `get_size` BIGINT(11) NOT NULL DEFAULT '0' COMMENT '',
  `add_time` datetime DEFAULT NULL COMMENT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='';
/*!40101 SET character_set_client = @saved_cs_client */;


INSERT INTO `jfrog_log` VALUES (1,'test_cluster', '2023-06-17 23:00:00', 'x.x.x.x', 2791, 56155441586, 7830, 121401422, '2018-02-01 00:00:00');
