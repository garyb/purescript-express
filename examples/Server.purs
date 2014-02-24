module Server where

import Prelude
import Control.Monad.Eff
import Debug.Trace
import Web.Express
import Web.Express.Middleware

index :: forall e. RouteHandler { msg :: String } (io :: IO | e)
index ctx = do
  send ctx.res 200 { msg: "Hello from express" }
  
ping :: forall e. RouteHandler String (io :: IO, trace :: Trace | e)
ping ctx = do
  print "Ping!"
  send ctx.res 200 "Pong"

main :: Eff (server :: Server (io :: IO, trace :: Trace)) {}
main = runExpress 8008 $ do
  
  get "/" index
  get "/ping" ping
  
  mount "/browse" $ directory "."
