

#nmap gr :w<cr>:!make push<cr>

push:
	git add .
	git commit -a -m "`date`"
	git push


pull:
	git pull


