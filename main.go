package main

import (
	"flag"
	"log"
	"net"
	"net/http"
	"os"
	"os/user"
	"strconv"
	"syscall"

	"golang.org/x/sys/unix"
)

type handler struct {
	mux  *http.ServeMux
	fsrv http.Handler
}

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.mux.ServeHTTP(w, r)
}

var addr string
var root string
var usr string

func getID(u string) (int, int, error) {
	var err error
	var uent *user.User

	isID := true
	for _, l := range u {
		if l < '0' || l > '9' {
			isID = false
			break
		}
	}

	if isID {
		uent, err = user.LookupId(u)
	} else {
		uent, err = user.Lookup(u)
	}
	if err != nil {
		return 0, 0, err
	}

	uid, err := strconv.Atoi(uent.Uid)
	if err != nil {
		return 0, 0, err
	}
	gid, err := strconv.Atoi(uent.Gid)
	if err != nil {
		return 0, 0, err
	}

	return uid, gid, nil
}

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	flag.StringVar(&addr, "l", "0.0.0.0:80", "HTTP listen address")
	flag.StringVar(&root, "r", "/var/www", "web server file root")
	flag.StringVar(&usr, "u", "www", "web server user")
	flag.Parse()

	// bind() now for privileged ports
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		return err
	}
	uid, gid, err := getID(usr)
	if err != nil {
		return err
	}

	if err := os.Chdir(root); err != nil {
		return err
	}
	if err := syscall.Chroot(root); err != nil {
		return err
	}
	if err := unix.Setgid(gid); err != nil {
		return err
	}
	if err := unix.Setgroups([]int{}); err != nil {
		return err
	}
	if err := unix.Setuid(uid); err != nil {
		return err
	}

	handler := &handler{
		mux:  http.NewServeMux(),
		fsrv: http.FileServer(http.Dir(".")),
	}
	handler.mux.Handle("GET /", handler.fsrv)
	handler.mux.HandleFunc("GET /favicon.ico", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "image/svg+xml")
		handler.fsrv.ServeHTTP(w, r)
	})

	srv := &http.Server{
		Handler: handler,
	}
	log.Printf("listening on %s", addr)
	return srv.Serve(ln)
}
