package main

import (
        "fmt"
        _ "github.com/bmizerany/pq"
        "database/sql"
        //"github.com/garyburd/gopkgdoc/doc"
        "github.com/garyburd/gopkgdoc/database"
        "regexp"
        "bytes"
        godoc "go/doc"
        //"net/http"
        //"time"
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
        fmt.Println(pkg.ImportPath)
        fmt.Println(pkg.Doc)
        var nsSql = "insert into namespaces (name, doc, version, library_id) values ($1, $2, '1.0.3', 1)"
        //var funSql = "insert into functions (name, doc, arglists_comp, version, url_friendly_name, namespace_id) values ($1, $2, $3, '1.0.3', $4, 4)"
        _, err = pg.Exec(nsSql, pkg.ImportPath, comment(pkg.Doc))
        if err != nil {
                panic(err)
        }

        //for _, fun := range pkg.Funcs {
        //        _, err = pg.Exec(funSql, fun.Name, fun.Doc, fun.Decl.Text, comment(fun.Name))
        //        if err != nil {
        //                panic(err)
        //        }
        //}

        //for _, t := range pkg.Types {
        //        fmt.Println(t.Name)
        //        fmt.Println(t.Decl.Text)
        //        fmt.Println(t.Doc)
        //        for _, fun := range t.Funcs {
        //                fmt.Println(fun.Name)
        //                fmt.Println(fun.Decl.Text)
        //                fmt.Println(fun.Doc)
        //        }
        //        for _, fun := range t.Methods {
        //                fmt.Println(fun.Name)
        //                fmt.Println(fun.Decl.Text)
        //                fmt.Println(fun.Doc)
        //        }

        //        for _, eg := range t.Examples {
        //                fmt.Println(eg.Name)
        //                fmt.Println(eg.Code.Text)
        //                fmt.Println(eg.Doc)
        //                fmt.Println(eg.Output)
        //        }
        //}
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
        return string(p)
}
