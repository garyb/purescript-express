module Web.Express.Middleware where

import Prelude
import Web.Express

type Cookie = { path :: String
              , httpOnly :: Boolean
              , maxAge :: Number }

defaultCookie :: Cookie
defaultCookie = { path: "/"
                , httpOnly: true
                , maxAge: 24 * 60 * 60 * 1000 }

type CookieSessionOptions = { key :: String
                            , secret :: String
                            , cookie :: Cookie
                            , proxy :: Boolean }

foreign import basicAuth "var basicAuth = require('express').basicAuth" :: String -> String -> Middleware
foreign import bodyParser "var bodyParser = require('express').bodyParser()" :: Middleware
foreign import compress "var compress = require('express').compress()" :: Middleware
foreign import cookieParser "var cookieParser = require('express').cookieParser" :: String -> Middleware
foreign import cookieSession "var cookieSession = require('express').cookieSession" :: CookieSessionOptions -> Middleware
foreign import csrf "var csrf = require('express').csrf()" :: Middleware
foreign import directory "var directory = require('express').directory" :: String -> Middleware
foreign import json "var json = require('express').json()" :: Middleware
foreign import multipart "var json = require('express').multipart()" :: Middleware
foreign import static "var directory = require('static').static" :: String -> Middleware
foreign import urlencoded "var urlencoded = require('express').urlencoded()" :: Middleware
