module Web.Express where

import Prelude
import Control.Monad
import Control.Monad.Eff

foreign import data Server :: # ! -> !
foreign import data IO :: !

foreign import data Express :: # ! -> *
foreign import data Middleware :: *
foreign import data Request :: *
foreign import data Response :: * -> *  

foreign import createE "var createE = require('express');" :: forall eff. {} -> Express eff

foreign import jsRoute
  "function jsRoute (args) { \
  \  return function (app) { \
  \    var handler1 = function (ctx) { args.handler(ctx)(); }; \
  \    app[args.verb].apply(app, [args.route, handler1]); \
  \    return app; \
  \  }; \
  \}" :: forall eff res. { verb :: String, route :: Route, handler :: RouteHandler res eff } -> Express eff -> Express eff
                                                        
foreign import jsMount
  "function jsMount (args) { \
  \  return function (app) { \
  \    app.use(args.route, args.middleware); \
  \    return app; \
  \  }; \
  \}" :: forall eff. { route :: Route, middleware :: Middleware } -> Express eff -> Express eff
                   
foreign import listen
  "function listen (app) { \
  \  return function (port) { \
  \    return function () { \
  \      app.listen(port); \
  \      return {}; \
  \    }; \
  \  }; \
  \}" :: forall e eff. Express eff -> Number -> Eff (server :: Server eff | e) {}
                      
foreign import send 
  "function send (res) { \
  \  return function (statusCode) { \
  \    return function (body) { \
  \      return function () { \
  \        res.send(statusCode, body); \
  \        return {}; \
  \      }; \
  \    }; \
  \  }; \
  \}" :: forall e eff a. Response a -> Number -> a -> Eff (io :: IO | e) {}

type Route = String
type URL = String
type HTTPStatus = Number

type RouteHandler res eff = HTTPContext res -> Eff eff {}

data HTTPVerb = GET | HEAD | POST | PUT | DELETE | TRACE | OPTIONS | CONNECT | PATCH
type HTTPContext res = { req :: Request, res :: Response res }

instance showHTTPVerb :: Prelude.Show HTTPVerb where
  show GET = "get"
  show HEAD = "head"
  show POST = "post"
  show PUT = "put"
  show DELETE = "delete"
  show TRACE = "trace"
  show OPTIONS = "options"
  show CONNECT = "connect"
  show PATCH = "patch"

data ExpressM eff a = ExpressM (Express eff -> { express :: Express eff, value :: a })

instance monadExpressM :: Prelude.Monad (ExpressM eff) where
  return x = ExpressM \e -> { express: e, value: x }
  (>>=) (ExpressM f) g = ExpressM \e -> 
    let { express = e', value = x } = f e in
      let ExpressM gx = g x in
        gx e'
        
modifyExpress :: forall eff. (Express eff -> Express eff) -> ExpressM eff {}
modifyExpress f = ExpressM \e -> { express: f e, value: {} }

runExpress :: forall e eff. Number -> ExpressM eff {} -> Eff (server :: Server eff | e) {}
runExpress port (ExpressM f) = listen (f $ createE {}).express port

route :: forall res eff. HTTPVerb -> Route -> RouteHandler res eff -> ExpressM eff {}
route verb route handler = modifyExpress $ 
  jsRoute { verb: (show verb), route: route, handler: handler }
  
mount :: forall eff. Route -> Middleware -> ExpressM eff {}
mount route mw = modifyExpress $
  jsMount { route: route, middleware: mw }

get :: forall res eff. Route -> RouteHandler res eff -> ExpressM eff {}
get = route GET

post :: forall res eff. Route -> RouteHandler res eff -> ExpressM eff {}
post = route POST

put :: forall res eff. Route -> RouteHandler res eff -> ExpressM eff {}
put = route PUT

delete :: forall res eff. Route -> RouteHandler res eff -> ExpressM eff {}
delete = route DELETE
