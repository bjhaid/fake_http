FakeHttp
========

FakeHttp is a fake http endpoint

### Usage

Start FakeHttp

```
> FakeHttp.start
true
```

Ask it for what url it is running on

```
> FakeHttp.url
"http://localhost:2000"
```

Call the URL

```
curl -d "hey" "http://localhost:2000?foo=bar"
curl -d "hi" "http://localhost:2000?foo=bar&bar=foo"
```

Ask FakeHttp questions

```
> FakeHttp.messages
["hey", "hi"]
> FakeHttp.last_message
"hi"
> FakeHttp.headers
[["user-agent": "curl/7.30.0", host: "localhost:2000", "content-length": "3",
  "content-type": "application/x-www-form-urlencoded"],
 ["user-agent": "curl/7.30.0", host: "localhost:2000", "content-length": "2",
  "content-type": "application/x-www-form-urlencoded"]]
> FakeHttp.last_header
["user-agent": "curl/7.30.0", host: "localhost:2000", "content-length": "2",
 "content-type": "application/x-www-form-urlencoded"]
> FakeHttp.query_params
[[foo: "bar"], [foo: "bar", bar: "foo"]]
> FakeHttp.last_query_param
[foo: "bar", bar: "foo"]
```

### Todos

Add SSL (Https) support
