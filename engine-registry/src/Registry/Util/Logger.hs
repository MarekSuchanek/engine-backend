module Registry.Util.Logger (
  logDebugU,
  logInfoU,
  logWarnU,
  logErrorU,
  LogLevel (..),
  module Shared.Constant.Component,
  module Shared.Util.Logger,
) where

import Control.Monad (when)
import Control.Monad.Logger (logWithoutLoc)
import Control.Monad.Reader (asks, liftIO)
import Data.Aeson (Value (..), toJSON)
import qualified Data.HashMap.Strict as HashMap
import qualified Data.Text as T
import qualified Data.UUID as U
import System.Log.Raven (initRaven, register, stderrFallback)
import System.Log.Raven.Transport.HttpConduit (sendRecord)
import System.Log.Raven.Types (SentryLevel (Error), SentryRecord (..))
import Prelude hiding (log)

import Registry.Model.Config.ServerConfig
import Registry.Model.Context.AppContext
import Registry.Model.Organization.Organization
import Shared.Constant.Component
import Shared.Model.Config.BuildInfoConfig
import Shared.Model.Config.ServerConfig hiding (email)
import Shared.Util.Logger

logDebugU :: String -> String -> AppContextM ()
logDebugU = logU LevelDebug

logInfoU :: String -> String -> AppContextM ()
logInfoU = logU LevelInfo

logWarnU :: String -> String -> AppContextM ()
logWarnU = logU LevelWarn

logErrorU :: String -> String -> AppContextM ()
logErrorU component message = do
  logU LevelError component message
  sendToSentry component message

-- ---------------------------------------------------------------------------
logU :: LogLevel -> String -> String -> AppContextM ()
logU logLevel component message = do
  mOrg <- asks currentOrganization
  traceUuid <- asks traceUuid
  let mOrgToken = fmap token mOrg
  let mTraceUuid = Just . U.toString $ traceUuid
  let record = createLogRecord logLevel mOrgToken mTraceUuid component message
  logWithoutLoc "" (LevelOther . T.pack . showLogLevel $ logLevel) record

sendToSentry :: String -> String -> AppContextM ()
sendToSentry component message = do
  mOrg <- asks currentOrganization
  traceUuid <- asks traceUuid
  serverConfig <- asks serverConfig
  when
    (serverConfig.sentry.enabled)
    ( do
        let sentryDsn = serverConfig.sentry.dsn
        sentryService <- liftIO $ initRaven sentryDsn id sendRecord stderrFallback
        buildInfoConfig <- asks buildInfoConfig
        let buildVersion = buildInfoConfig.version
        liftIO $ register sentryService "messageLogger" Error message (recordUpdate buildVersion mOrg traceUuid)
    )

recordUpdate :: String -> Maybe Organization -> U.UUID -> SentryRecord -> SentryRecord
recordUpdate buildVersion mOrg traceUuid record =
  let orgUuid = T.pack . maybe "" organizationId $ mOrg
      orgEmail = T.pack . maybe "" email $ mOrg
   in record
        { srRelease = Just buildVersion
        , srInterfaces =
            HashMap.fromList
              [
                ( "sentry.interfaces.User"
                , toJSON $ HashMap.fromList [("id", String orgUuid), ("email", String orgEmail)]
                )
              ]
        , srTags = HashMap.fromList [("traceUuid", U.toString traceUuid)]
        , srExtra = HashMap.fromList [("traceUuid", String . T.pack . U.toString $ traceUuid)]
        }
