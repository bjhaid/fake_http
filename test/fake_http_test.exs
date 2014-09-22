defmodule FakeHttpTest do
  use ExUnit.Case, async: true

  setup do
    FakeHttp.start
    on_exit fn -> FakeHttp.stop end
  end

  test "messages" do
    System.cmd("curl", ["-sd", "{\"foo\": \"bar\"}", FakeHttp.url])
    System.cmd("curl", ["-sd", "hey", FakeHttp.url])
    assert FakeHttp.messages == ["{\"foo\": \"bar\"}", "hey"]
    assert length(FakeHttp.messages) == 2
  end

  test "last_message" do
    System.cmd("curl", ["-sd", "{\"foo\": \"bar\"}", FakeHttp.url])
    System.cmd("curl", ["-sd", "hey", FakeHttp.url])
    assert FakeHttp.last_message == "hey"
  end

  test "headers" do
    System.cmd("curl", ["-sd", "{\"foo\": \"bar\"}", FakeHttp.url])
    System.cmd("curl", ["-sd", "hey", FakeHttp.url])
    assert length(FakeHttp.headers) == 2
  end

  test "last_header" do
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url])
    System.cmd("curl", ["-H", "xfoo: bar", "-sd", "hey", FakeHttp.url])
    {_, xfoo} = :proplists.lookup(:xfoo, FakeHttp.last_header)
    assert xfoo == "bar"
  end

  test "query_params" do
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url <> "/user?foo=bar"])
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url <> "/users"])
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url <> "/user/friend?bar=foo"])
    assert FakeHttp.query_params == [[foo: "bar"], [bar: "foo"]]
    assert length(FakeHttp.query_params) == 2
  end

  test "parses multiple query_params correctly" do
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url <> "/user?foo=bar"])
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url <> "/users"])
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url <> "/user/friend?bar=foo&foo=bar"])
    assert FakeHttp.query_params == [[foo: "bar"], [bar: "foo", foo: "bar"]]
    assert length(FakeHttp.query_params) == 2
  end

  test "last_query_param" do
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url <> "/user/friend?bar=foo"])
    System.cmd("curl", ["-sd {\"foo\": \"bar\"}", FakeHttp.url <> "/user?foo=bar"])
    assert FakeHttp.last_query_param == [foo: "bar"]
  end
end
