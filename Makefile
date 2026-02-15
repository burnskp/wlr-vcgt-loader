PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

PKG_CONFIG ?= pkg-config
WAYLAND_SCANNER ?= $(shell $(PKG_CONFIG) --variable=wayland_scanner wayland-scanner 2>/dev/null || echo wayland-scanner)

CFLAGS += -std=c11 -O2 -Wall -Wextra
CFLAGS += $(shell $(PKG_CONFIG) --cflags wayland-client lcms2)

LDLIBS += $(shell $(PKG_CONFIG) --libs wayland-client lcms2) -lm

PROTO_XML = protocol/wlr-gamma-control-unstable-v1.xml
PROTO_C   = wlr-gamma-control-unstable-v1-protocol.c
PROTO_H   = wlr-gamma-control-unstable-v1-client-protocol.h

OBJS = main.o $(PROTO_C:.c=.o)

all: wlr-vcgt-loader

$(PROTO_C): $(PROTO_XML)
	$(WAYLAND_SCANNER) private-code $< $@

$(PROTO_H): $(PROTO_XML)
	$(WAYLAND_SCANNER) client-header $< $@

$(PROTO_C:.c=.o): $(PROTO_C) $(PROTO_H)

main.o: main.c $(PROTO_H)

wlr-vcgt-loader: $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS) $(LDLIBS)

install: wlr-vcgt-loader
	install -Dm755 wlr-vcgt-loader $(DESTDIR)$(BINDIR)/wlr-vcgt-loader

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/wlr-vcgt-loader

clean:
	rm -f wlr-vcgt-loader $(OBJS) $(PROTO_C) $(PROTO_H)

.PHONY: all install uninstall clean
