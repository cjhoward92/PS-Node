module Main where

import Prelude

import Control.Monad.Eff (Eff, runPure)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Aff (Aff, makeAff, launchAff)
import Control.Monad.Aff.Console as AffConsole

import Data.Foldable (foldMap)
import Data.Maybe (Maybe(..), fromMaybe)

import Node.Encoding (Encoding(..))
import Node.HTTP (HTTP, listen, createServer, setHeader, requestMethod, requestURL, responseAsStream, requestAsStream, setStatusCode)
import Node.HTTP.Client as Client
import Node.Stream (Writable, Readable, end, pipe)
import Node.Buffer as Buffer

foreign import stdout :: forall eff r. Writable r eff
foreign import outputStream :: forall eff r. Writable r eff
foreign import streamToBuffer :: forall e w. (Buffer.Buffer -> Eff e Unit) -> Readable w e -> Eff e Unit

main :: forall e. Eff (console :: CONSOLE, http :: HTTP, exception :: EXCEPTION, buffer :: Buffer.BUFFER | e) Unit
main = do
  log "Hello sailor!"
  req <- Client.requestFromURI "http://localhost:3000/complaints" \response -> void do
    log "Version: "
    logShow $ Client.httpVersion response
    log "Headers: "
    logShow $ Client.responseHeaders response
    log "Response: "
    let responseStream = Client.responseAsStream response
    -- pipe responseStream outputStream
    launchAff $ do
      buf <- streamToBuffer' responseStream
      AffConsole.logShow $ buf
    
  end (Client.requestAsStream req) (pure unit)

streamToBuffer' :: forall e w. Readable w e -> Aff e Buffer.Buffer
streamToBuffer' stream = makeAff (\err success -> streamToBuffer success stream)