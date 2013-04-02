package main

import (
	"bytes"
	"database/sql"
	"fmt"
	"github.com/garyburd/gopkgdoc/database"
	"github.com/garyburd/gopkgdoc/doc"
	_ "github.com/lib/pq"
	godoc "go/doc"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)

type timeoutConn struct {
	net.Conn
}

var dialTimeout = 30 * time.Second

func timeoutDial(network, addr string) (net.Conn, error) {
	c, err := net.DialTimeout(network, addr, dialTimeout)
	if err != nil {
		return nil, err
	}
	return &timeoutConn{Conn: c}, nil
}

var httpTransport = &http.Transport{Dial: timeoutDial}
var httpClient = &http.Client{Transport: httpTransport}

func main() {
	db, err := database.New()
	if err != nil {
		panic(err)
	}
	pg, err := sql.Open("postgres", "user=isaiah dbname=clojuredocs_development sslmode=disable")
	defer pg.Close()
	if err != nil {
		panic(err)
	}
	_, err = pg.Exec("delete from functions")
	check(err)
	_, err = pg.Exec("delete from type_classes")
	check(err)
	_, err = pg.Exec("delete from namespaces")
	check(err)

	nextCrawl := time.Now()
	nextCrawl.Add(time.Hour)

	crawlJobs := make(chan string, 10)
	storeJobs := make(chan string, 10)
	done := make(chan bool)
	etag := ""
	go func() {
		for {
			pkgName, more := <-crawlJobs
			if more {
				if pkgName == "" || pkgName == "go/format" || pkgName == "net/http/cookiejar" || pkgName == "runtime/race" {
					continue
				} else {
					pkg, _ := doc.Get(httpClient, pkgName, etag)
					err := db.Put(pkg, nextCrawl)
					if err != nil {
						fmt.Println("failed!!!!!!!!!!!!!!!!!!!!!!", pkgName)
						continue
					}
					storeJobs <- pkgName
					httpTransport.CloseIdleConnections()
				}
			} else {
				close(storeJobs)
				return
			}
		}
	}()

	go func() {
		for {
			pkgName, more := <-storeJobs
			if more {
				store(pkgName, db, pg)
			} else {
				done <- true
				return
			} // end of if
		} // end of for

	}()
	root := "/home/isaiah/codes/go/go/src/pkg/"
	filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			panic(err)
		}
		if info.IsDir() && !strings.Contains(path, "testdata") {
			pkgName := strings.Split(path, root)
			fmt.Println(pkgName[1])
			crawlJobs <- pkgName[1]
		}
		return nil
	})
	close(crawlJobs)

	<-done
}

func store(pkgName string, db *database.Database, pg *sql.DB) {
	pkg, _, _, err := db.Get(pkgName)
	if err != nil {
		panic(err)
	}
	nsSql, err := pg.Prepare("insert into namespaces (name, doc, version, library_id) values ($1, $2, '1.0.3', 1) RETURNING id")
	check(err)
	funSql, err := pg.Prepare("insert into functions (name, doc, arglists_comp, version, url_friendly_name, functional_id, functional_type) values ($1, $2, $3, '1.0.3', $4, $5, $6)")
	check(err)
	typeSql, err := pg.Prepare("insert into type_classes (name, doc, arglists_comp, type, namespace_id, version, created_at, updated_at) values ($1, $2, $3, 'StructType', $4, '1.0.3', $5, $6) RETURNING id")
	check(err)
	var nsId int
	err = nsSql.QueryRow(pkg.ImportPath, comment(pkg.Doc)).Scan(&nsId)
	if err != nil {
		panic(err)
	}
	now := time.Now()

	for _, fun := range pkg.Funcs {
		_, err = funSql.Exec(fun.Name, comment(fun.Doc), fun.Decl.Text, fun.Name, nsId, "Namespace")
		if err != nil {
			panic(err)
		}
	}

	for _, t := range pkg.Types {
		var id int
		err = typeSql.QueryRow(t.Name, comment(t.Doc), "<pre>"+t.Decl.Text+"</pre>", nsId, now, now).Scan(&id)
		check(err)
		for _, fun := range t.Funcs {
			_, err = funSql.Exec(fun.Name, comment(fun.Doc), fun.Decl.Text, fun.Name, id, "TypeClass")
			if err != nil {
				panic(err)
			}
		}

		for _, fun := range t.Methods {
			_, err = funSql.Exec(fun.Name, comment(fun.Doc), fun.Decl.Text, fun.Name, id, "TypeClass")
			if err != nil {
				panic(err)
			}
		}

		//for _, eg := range t.Examples {
		//        fmt.Println(eg.Name)
		//        fmt.Println(eg.Code.Text)
		//        fmt.Println(eg.Doc)
		//        fmt.Println(eg.Output)
		//}
	}
}

var (
	h3Open            = []byte("<h3 ")
	h4Open            = []byte("<h4 ")
	h3Close           = []byte("</h3>")
	h4Close           = []byte("</h4>")
	rfcRE             = regexp.MustCompile(`RFC\s+(\d{3,4})`)
	rfcReplace        = []byte(`<a href="http://tools.ietf.org/html/rfc$1">$0</a>`)
	pre               = []byte("<pre")
	shBrush           = []byte("<pre class=\"brush: go\"")
	stopLink          = make(map[string]string)
	linkInCode        = regexp.MustCompile(`(<pre(?:.*?(?:\n))*.*?)<a\s+href="(?:.*?)">(.*?)</a>((?:.*?(?:\n)?.*?)*?</pre>)`)
	linkInCodeReplace = []byte(`$1$2$3`)
)

func comment(v string) string {
	var buf bytes.Buffer
	godoc.ToHTML(&buf, v, stopLink)
	p := buf.Bytes()
	p = bytes.Replace(p, h3Open, h4Open, -1)
	p = bytes.Replace(p, h3Close, h4Close, -1)
	p = bytes.Replace(p, pre, shBrush, -1)
	p = rfcRE.ReplaceAll(p, rfcReplace)
	// rollback the links in code
	//p = linkInCode.ReplaceAll(p, linkInCodeReplace)
	//fmt.Println(string(p))
	return string(p)
}
func check(err error) {
	if err != nil {
		panic(err)
	}
}
