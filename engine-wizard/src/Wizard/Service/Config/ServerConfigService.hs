module Wizard.Service.Config.ServerConfigService where

import Control.Lens (Lens', (&), (.~), (^.))
import Data.Maybe (fromMaybe)
import Data.Yaml (decodeFileEither)
import System.Environment (lookupEnv)

import LensesConfig
import Shared.Model.Error.Error
import Wizard.Model.Config.ServerConfig
import Wizard.Model.Config.ServerConfigJM ()

getServerConfig :: String -> IO (Either AppError ServerConfig)
getServerConfig fileName = do
  eConfig <- decodeFileEither fileName
  case eConfig of
    Right config -> return config >>= applyEnvVariable "FEEDBACK_TOKEN" (feedback . token) >>= (return . Right)
    Left error -> return . Left . GeneralServerError . show $ error
  where
    applyEnvVariable :: String -> Lens' ServerConfig String -> ServerConfig -> IO ServerConfig
    applyEnvVariable envVariableName accessor config = do
      envVariable <- lookupEnv envVariableName
      let newValue = fromMaybe (config ^. accessor) envVariable
      return $ config & accessor .~ newValue
