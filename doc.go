package main

import (
        "fmt"
        _ "github.com/lib/pq"
        "database/sql"
        //"github.com/garyburd/gopkgdoc/doc"
        "github.com/garyburd/gopkgdoc/database"
        "regexp"
        "bytes"
        godoc "go/doc"
        //"net/http"
        "time"
)

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
        rows, err := pg.Query("select name from functions")
        if err != nil {
                panic(err)
        }
        defer rows.Close()
        for rows.Next() {
                var name string
                rows.Scan(&name)
                fmt.Println(name)
        }
        //etag := ""
        //pkg, _ := doc.Get(httpClient, "net/http", etag)
        //nextCrawl := time.Now()
        //nextCrawl.Add(time.Hour)
        //db.Put(pkg, nextCrawl)
        stopLink["http://example.com"] = ""
        pkg, _, _, err := db.Get("net/http")
        if err != nil {
                panic(err)
        }
        //var nsSql = pg.Prepare("insert into namespaces (name, doc, version, library_id) values ($1, $2, '1.0.3', 1)")
        funSql, err := pg.Prepare("insert into functions (name, doc, arglists_comp, version, url_friendly_name, functional_id, functional_type) values ($1, $2, $3, '1.0.3', $4, $5, $6)")
        check(err)
        typeSql := "insert into type_classes (name, doc, arglists_comp, type, namespace_id, version, created_at, updated_at) values ($1, $2, $3, 'StructType', 25, '1.0.3', $4, $5) RETURNING id"
        check(err)
        //_, err = pg.Exec(nsSql, pkg.ImportPath, comment(pkg.Doc))
        //if err != nil {
        //        panic(err)
        //}
        now := time.Now()

        for _, fun := range pkg.Funcs {
                _, err = funSql.Exec(fun.Name, comment(fun.Doc), fun.Decl.Text, fun.Name, 25, "Namespace")
                if err != nil {
                        panic(err)
                }
        }

        for _, t := range pkg.Types {
                var id int
                err = pg.QueryRow(typeSql, t.Name, comment(t.Doc), t.Decl.Text, now, now).Scan(&id)
                check(err)
                fmt.Println("TypeClass ID", id)
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
        h3Open     = []byte("<h3 ")
        h4Open     = []byte("<h4 ")
        h3Close    = []byte("</h3>")
        h4Close    = []byte("</h4>")
        rfcRE      = regexp.MustCompile(`RFC\s+(\d{3,4})`)
        rfcReplace = []byte(`<a href="http://tools.ietf.org/html/rfc$1">$0</a>`)
        pre        = []byte("<pre")
        shBrush    = []byte("<pre class=\"brush: go\"")
        stopLink   = make(map[string]string)
        linkInCode = regexp.MustCompile(`(<pre(?:.*?(?:\n))*.*?)<a\s+href="(?:.*?)">(.*?)</a>((?:.*?(?:\n)?.*?)*?</pre>)`)
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
