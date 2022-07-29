{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}

module InbetweenHKD (
  Config' (..),
  DefaultConfig,
  PartialConfig,
  Config,
  defaultConfig,
  getConfig,
) where

import Data.Functor.Identity (Identity (Identity))
import Data.Maybe (fromMaybe)
import Data.Proxy (Proxy (Proxy))
import System.Environment (lookupEnv)
import Text.Read (readMaybe)

-- | A higher kinded config data type
data Config' static dynamic = Config
  { password :: dynamic String
  , serviceUrl :: static String
  , servicePort :: static Int
  }

-- | Derives a Show instance for the Config' type.
-- This is not strictly needed.
deriving instance
  ( Show (dynamic String)
  , Show (static String)
  , Show (static Int)
  ) =>
  Show (Config' static dynamic)

type DefaultConfig = Config' Identity Proxy

type PartialConfig = Config' Maybe Identity

type Config = Config' Identity Identity

-- | DefaultConfig defining all statically known values
defaultConfig :: DefaultConfig
defaultConfig =
  Config
    { password = Proxy
    , serviceUrl = Identity "localhost"
    , servicePort = Identity 8080
    }

-- | Construct a PartialConfig from environment variables
readinPartialConfig :: IO PartialConfig
readinPartialConfig =
  Config
    <$> (Identity <$> getPassword)
    <*> getUrl
    <*> getPort

getPassword :: IO String
getPassword =
  fromMaybe (error "Environment variable PASSWORD not set")
    <$> lookupEnv "PASSWORD"

getUrl :: IO (Maybe String)
getUrl = lookupEnv "SERVICE_URL"

getPort :: IO (Maybe Int)
getPort = (readMaybe =<<) <$> lookupEnv "SERVICE_PORT"

-- | combines a DefaultConfig and PartialConfig, using values from
-- the partial config if present.
combineConfig :: DefaultConfig -> PartialConfig -> Config
combineConfig
  (Config _defaultPasswordProxy defaultServiceURL defaultServicePort)
  (Config pw url port) =
    Config
      pw
      (maybe defaultServiceURL Identity url)
      (maybe defaultServicePort Identity port)

-- | Gets a complete Config
getConfig :: IO Config
getConfig = combineConfig defaultConfig <$> readinPartialConfig

-- Vorteile:
-- aus der Definition von Config ist klar zu erkennen welche Parameter statisch bekannt sind
--    und welche zur Laufzeit ermittelt werden
-- default Konfiguration ist getrennt von dem einlesen der einzelnen Parameter

-- Probleme:
-- Code ist immernoch nicht wiederverwendbar
-- beim definieren von `defaultConfig` und `readinPartialConfig` muss `Proxy` und `Identity` verwendet werden
