deploy:
	nom build .#
	npm run wisp -- deploy bwc9876.dev --path ./result --site website

