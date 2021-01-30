NAME = walsh

PREFIX ?= /usr
START ?= /etc/xdg/autostart
DOCS ?= $(PREFIX)/share/doc/$(NAME)
LICENSE ?= $(PREFIX)/share/licenses/$(NAME)

install-bin:
	@echo installing $(NAME)...
	install -Dm 755 $(NAME).zsh $(PREFIX)/bin/$(NAME)

install-autostart:
	install -Dm 644 autostart/$(NAME).desktop $(START)/$(NAME).desktop

install-docs:
	install -Dm 644 docs/example.rc $(DOCS)/example.rc
	install -Dm 644 README.md $(DOCS)/README.md
	install -Dm 644 LICENSE $(LICENSE)/LICENSE

uninstall:
	@echo removing $(NAME)...
	rm -f $(PREFIX)/bin/$(NAME)
	rm -rf $(DOCS)
	rm -rf $(LICENSE)
	rm -f $(START)/$(NAME).desktop

install: install-bin install-autostart install-docs
