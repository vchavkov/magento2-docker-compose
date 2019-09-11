# clean up all docker instances
docker rm -f $(docker ps -a -q);

# clean up all docker images
docker rmi $(docker images -q)