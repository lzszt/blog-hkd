{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE StandaloneKindSignatures #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

module WithHKD (
  -- | Library functionallity
  HKD,
  genericApply,
  Default,
  Partial,
  Complete,
  dynamic,
  -- | Config specific part
  Config' (..),
  DefaultConfig,
  PartialConfig,
  Config,
  defaultConfig,
  getConfig,
) where

import Data.Kind (Type)
import Data.Maybe (fromMaybe)
import GHC.Generics (Generic)
import HKD
import System.Environment (lookupEnv)
import Text.Read (readMaybe)

-- | A higher kinded config data type
type Config' :: (Type -> Type) -> (Type -> Type) -> Type
data Config' static dynamic = Config
  { password :: HKD dynamic String
  , serviceUrl :: HKD static String
  , servicePort :: HKD static Int
  }
  deriving (Generic)

-- | Derives a Show instance for the Config' type.
-- This is not strictly needed.
deriving instance
  ( Show (HKD dynamic String)
  , Show (HKD static String)
  , Show (HKD static Int)
  ) =>
  Show (Config' static dynamic)

type DefaultConfig = Default Config'

type PartialConfig = Partial Config'

type Config = Complete Config'

-- | DefaultConfig defining all statically known values
defaultConfig :: DefaultConfig
defaultConfig =
  Config
    { password = dynamic
    , serviceUrl = "localhost"
    , servicePort = 8080
    }

-- | Construct a PartialConfig from environment variables
readinPartialConfig :: IO PartialConfig
readinPartialConfig =
  Config
    <$> getPassword
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

-- | Gets a complete Config
getConfig :: IO Config
getConfig =
  genericApply defaultConfig <$> readinPartialConfig

-- Vorteile:
-- nur relevante Teile des Codes müssen neu geschrieben werden
-- Usercode kommt ohne `Proxy` und `Identity` aus