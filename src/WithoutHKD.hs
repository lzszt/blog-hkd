module WithoutHKD (
  Config (..),
  getConfig,
) where

import Data.Maybe (fromMaybe)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)

-- | A config type
data Config = Config
  { password :: String
  , serviceUrl :: String
  , servicePort :: Int
  }
  deriving (Show)

-- | Read in some configuration options from environment variables
-- if the environment variable is not present or cannot be parsed
-- use default values
getConfig :: IO Config
getConfig = do
  pw <- getPassword
  url <- fromMaybe "localhost" <$> getUrl
  port <- fromMaybe 8080 <$> getPort
  pure $ Config pw url port

getPassword :: IO String
getPassword =
  fromMaybe (error "Environment variable PASSWORD not set")
    <$> lookupEnv "PASSWORD"

getUrl :: IO (Maybe String)
getUrl = lookupEnv "SERVICE_URL"

getPort :: IO (Maybe Int)
getPort = (readMaybe =<<) <$> lookupEnv "SERVICE_PORT"

-- Probleme:
-- lesen der einzelnen Parameter ist vermischt mit den default Werten
-- Code muss für jede Konfiguration neu geschrieben werden
-- Nicht direkt klar ob ein Feld einene default Wert hat